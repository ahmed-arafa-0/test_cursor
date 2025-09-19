import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:developer';

part 'countdown_state.dart';

class CountdownCubit extends Cubit<CountdownState> {
  CountdownCubit({DateTime? targetDate}) : super(CountdownInitial()) {
    _setTargetDate(targetDate);
    _initializeCountdown();
  }

  late DateTime _targetDate;
  Timer? _timer;

  // Cairo, Egypt timezone offset (+2 hours)
  static const Duration _cairoOffset = Duration(hours: 2);

  DateTime get targetDate => _targetDate;

  void _setTargetDate(DateTime? targetDate) {
    if (targetDate != null) {
      _targetDate = targetDate;
    } else {
      // Default: Veuolla's birthday September 26, 2025 in Cairo timezone
      final now = DateTime.now().toUtc().add(_cairoOffset);
      _targetDate = DateTime(2025, 9, 26, 0, 0, 0); // Midnight on birthday
    }

    log('Target date set to: $_targetDate (Cairo time)');
  }

  void _initializeCountdown() {
    _updateCountdown();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
    log('Countdown timer started');
  }

  void _updateCountdown() {
    try {
      // Get current time in Cairo timezone
      final nowUtc = DateTime.now().toUtc();
      final nowCairo = nowUtc.add(_cairoOffset);

      // Calculate difference
      final difference = _targetDate.difference(nowCairo);

      if (difference.isNegative) {
        // Birthday has passed
        emit(CountdownFinished(message: '🎉 Happy Birthday Veuolla! 🎂'));
        _timer?.cancel();
        log('Birthday reached! Countdown finished.');
      } else if (difference.inDays == 0 &&
          difference.inHours == 0 &&
          difference.inMinutes == 0 &&
          difference.inSeconds <= 10) {
        // Final countdown (last 10 seconds)
        emit(
          CountdownFinalSeconds(
            seconds: difference.inSeconds,
            totalDuration: difference,
          ),
        );
        log('Final countdown: ${difference.inSeconds} seconds remaining');
      } else {
        // Normal countdown
        final days = difference.inDays;
        final hours = difference.inHours.remainder(24);
        final minutes = difference.inMinutes.remainder(60);
        final seconds = difference.inSeconds.remainder(60);

        emit(
          CountdownTicking(
            days: days,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            totalDuration: difference,
            cairoTime: nowCairo,
            targetTime: _targetDate,
          ),
        );

        // Log milestone moments
        if (days > 0 && hours == 0 && minutes == 0 && seconds == 0) {
          log('Milestone: $days days remaining');
        }
      }
    } catch (e, stackTrace) {
      log('Error updating countdown: $e', stackTrace: stackTrace);
      emit(CountdownError(message: 'Error calculating time: $e'));
    }
  }

  /// Set new target date
  void setTargetDate(DateTime newDate) {
    log('Changing target date from $_targetDate to $newDate');
    _targetDate = newDate;
    _updateCountdown();
  }

  /// Get time until birthday in human readable format
  String getTimeUntilBirthday() {
    if (state is CountdownTicking) {
      final tickingState = state as CountdownTicking;
      final days = tickingState.days;
      final hours = tickingState.hours;
      final minutes = tickingState.minutes;

      if (days > 0) {
        return '$days days, $hours hours, $minutes minutes';
      } else if (hours > 0) {
        return '$hours hours, $minutes minutes';
      } else {
        return '$minutes minutes';
      }
    }
    return 'Calculating...';
  }

  /// Check if birthday is today
  bool get isBirthdayToday {
    final nowUtc = DateTime.now().toUtc();
    final nowCairo = nowUtc.add(_cairoOffset);

    return nowCairo.year == _targetDate.year &&
        nowCairo.month == _targetDate.month &&
        nowCairo.day == _targetDate.day;
  }

  /// Check if birthday is this week
  bool get isBirthdayThisWeek {
    if (state is! CountdownTicking) return false;
    final tickingState = state as CountdownTicking;
    return tickingState.totalDuration.inDays <= 7;
  }

  /// Get current Cairo time
  DateTime getCurrentCairoTime() {
    return DateTime.now().toUtc().add(_cairoOffset);
  }

  /// Pause countdown (for testing)
  void pause() {
    _timer?.cancel();
    emit(CountdownPaused(previousState: state));
    log('Countdown paused');
  }

  /// Resume countdown
  void resume() {
    if (state is CountdownPaused) {
      _startTimer();
      log('Countdown resumed');
    }
  }

  /// Reset countdown to original target
  void reset() {
    _setTargetDate(DateTime(2025, 9, 26, 0, 0, 0));
    _updateCountdown();
    log('Countdown reset to original date');
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    log('Countdown cubit closed');
    return super.close();
  }
}
