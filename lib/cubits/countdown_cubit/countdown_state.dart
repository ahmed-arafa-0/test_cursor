part of 'countdown_cubit.dart';

@immutable
sealed class CountdownState {}

final class CountdownInitial extends CountdownState {}

final class CountdownTicking extends CountdownState {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final Duration totalDuration;
  final DateTime cairoTime;
  final DateTime targetTime;

  CountdownTicking({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.totalDuration,
    required this.cairoTime,
    required this.targetTime,
  });

  /// Get formatted countdown string
  String get formattedCountdown => '${days}d ${hours}h ${minutes}m ${seconds}s';

  /// Check if it's the final day
  bool get isFinalDay => days == 0;

  /// Check if it's the final hour
  bool get isFinalHour => days == 0 && hours == 0;

  /// Get progress percentage (0.0 to 1.0)
  double getProgress(DateTime startDate) {
    final totalDuration = targetTime.difference(startDate);
    final remaining = totalDuration;
    if (totalDuration.inSeconds == 0) return 1.0;
    return 1.0 - (remaining.inSeconds / totalDuration.inSeconds);
  }
}

final class CountdownFinalSeconds extends CountdownState {
  final int seconds;
  final Duration totalDuration;

  CountdownFinalSeconds({required this.seconds, required this.totalDuration});
}

final class CountdownFinished extends CountdownState {
  final String message;

  CountdownFinished({required this.message});
}

final class CountdownError extends CountdownState {
  final String message;

  CountdownError({required this.message});
}

final class CountdownPaused extends CountdownState {
  final CountdownState previousState;

  CountdownPaused({required this.previousState});
}
