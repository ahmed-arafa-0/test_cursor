part of 'background_cubit.dart';

@immutable
sealed class BackgroundCubitState {}

final class PictureBackgroundAssetState extends BackgroundCubitState {
  final String assetPath;
  PictureBackgroundAssetState({required this.assetPath});
}

final class PictureBackgroundNetworkState extends BackgroundCubitState {
  final String networkUrl;
  PictureBackgroundNetworkState({required this.networkUrl});
}

final class VideoBackgroundAssetState extends BackgroundCubitState {
  final String assetPath;
  VideoBackgroundAssetState({required this.assetPath});
}

final class VideoBackgroundNetworkState extends BackgroundCubitState {
  final String networkUrl;
  VideoBackgroundNetworkState({required this.networkUrl});
}

final class BackgroundLoadingState extends BackgroundCubitState {}

final class BackgroundErrorState extends BackgroundCubitState {
  final String message;
  BackgroundErrorState({required this.message});
}
