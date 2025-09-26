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
  final DateTime testDate = DateTime.now().add(Duration(seconds: 15));
  DateTime get targetDate => _targetDate;

  void _setTargetDate(DateTime? targetDate) {
    // if (targetDate != null) {
    //   // Set target date to midnight Cairo time on the birthday
    //   _targetDate = DateTime(
    //     targetDate.year,
    //     targetDate.month,
    //     targetDate.day,
    //     0,
    //     0,
    //     0,
    //   );
    // } else {
    //   // Default: Veuolla's birthday September 26, 2025 at midnight Cairo time
    //   _targetDate = DateTime(2025, 9, 26, 0, 0, 0);
    // }

    // log('Target date set to: $_targetDate (Cairo time)');

    // FOR IMMEDIATE TESTING - SET TO 10 SECONDS FROM NOW:
    // final now = DateTime.now();
    _targetDate = DateTime.now().add(Duration(seconds: 20));

    log('Target date set to: $_targetDate (10 seconds from now)');
  }

  /// Get current time in Cairo timezone - FIXED: Simple +4 hours (was +2, now +4 to show 2 hours more)
  DateTime _getCairoTime() {
    final utcNow = DateTime.now().toUtc();
    return utcNow.add(
      const Duration(hours: 0),
    ); // CHANGED: +4 hours instead of +2 to add 2 more hours
  }

  /// Convert Cairo time to proper display format
  String _formatCairoTime(DateTime cairoTime) {
    final hour = cairoTime.hour;
    final minute = cairoTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
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
      // Get current Cairo time (now +4 hours to show 2 more hours in countdown)
      final nowCairo = _getCairoTime();

      // Create target date in Cairo timezone (September 26, 2025 at midnight Cairo time)
      final targetCairo = testDate;
      // final targetCairo = DateTime(2025, 9, 26, 0, 0, 0);

      // Calculate difference
      final difference = targetCairo.difference(nowCairo);

      // log('Current Cairo time: $nowCairo');
      // log('Target Cairo time: $targetCairo');
      // log(
      // 'Difference: ${difference.inDays} days, ${difference.inHours % 24} hours, ${difference.inMinutes % 60} minutes',
      // );

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
            targetTime: targetCairo,
            cairoTimeFormatted: _formatCairoTime(nowCairo),
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
    _setTargetDate(newDate);
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
    final nowCairo = _getCairoTime();
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
    return _getCairoTime();
  }

  /// Get formatted Cairo time string
  String getFormattedCairoTime() {
    return _formatCairoTime(_getCairoTime());
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
