part of 'content_cubit.dart';

@immutable
sealed class ContentState {}

final class ContentInitial extends ContentState {}

final class ContentInitializing extends ContentState {}

final class ContentLoading extends ContentState {}

final class ContentLoaded extends ContentState {
  final DailyContent content;

  ContentLoaded({required this.content});
}

final class ContentError extends ContentState {
  final String message;
  final DailyContent fallbackContent;

  ContentError({required this.message, required this.fallbackContent});
}

final class ContentRefreshing extends ContentState {
  final DailyContent currentContent;

  ContentRefreshing({required this.currentContent});
}
