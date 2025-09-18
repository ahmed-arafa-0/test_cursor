part of 'background_cubit.dart';

@immutable
sealed class BackgroundCubitState {}

final class PictureBackgroundAssetState extends BackgroundCubitState {}

final class PictureBackgroundNetworkState extends BackgroundCubitState {}

final class VideoBackgroundAssetState extends BackgroundCubitState {}

final class VideoBackgroundNetworkState extends BackgroundCubitState {}

final class BackgroundLoadingState extends BackgroundCubitState {}

final class BackgroundErrorState extends BackgroundCubitState {}
