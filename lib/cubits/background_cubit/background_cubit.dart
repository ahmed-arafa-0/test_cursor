import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'background_state.dart';

class BackgroundCubit extends Cubit<BackgroundCubitState> {
  BackgroundCubit() : super(BackgroundLoadingState());

  bool isPicture = true;
  bool fromNetwork = false;
  String? currentAssetPath;
  String? currentNetworkUrl;

  // Initialize with default background
  void initialize() {
    emit(BackgroundLoadingState());
    // Start with asset picture by default
    currentAssetPath = 'assets/images/default.jpg';
    emit(PictureBackgroundAssetState(assetPath: currentAssetPath!));
  }

  // Toggle between picture and video
  void toggleMediaType() {
    isPicture = !isPicture;
    emit(BackgroundLoadingState());

    if (isPicture) {
      if (fromNetwork && currentNetworkUrl != null) {
        emit(PictureBackgroundNetworkState(networkUrl: currentNetworkUrl!));
      } else if (currentAssetPath != null) {
        emit(PictureBackgroundAssetState(assetPath: currentAssetPath!));
      }
    } else {
      if (fromNetwork && currentNetworkUrl != null) {
        emit(VideoBackgroundNetworkState(networkUrl: currentNetworkUrl!));
      } else if (currentAssetPath != null) {
        emit(VideoBackgroundAssetState(assetPath: currentAssetPath!));
      }
    }
  }

  // Toggle between network and asset
  void toggleSource() {
    fromNetwork = !fromNetwork;
    emit(BackgroundLoadingState());

    if (isPicture) {
      if (fromNetwork && currentNetworkUrl != null) {
        emit(PictureBackgroundNetworkState(networkUrl: currentNetworkUrl!));
      } else if (currentAssetPath != null) {
        emit(PictureBackgroundAssetState(assetPath: currentAssetPath!));
      }
    } else {
      if (fromNetwork && currentNetworkUrl != null) {
        emit(VideoBackgroundNetworkState(networkUrl: currentNetworkUrl!));
      } else if (currentAssetPath != null) {
        emit(VideoBackgroundAssetState(assetPath: currentAssetPath!));
      }
    }
  }

  // Set specific asset
  void setAsset(String path, bool isVideo) {
    currentAssetPath = path;
    fromNetwork = false;
    isPicture = !isVideo;
    emit(BackgroundLoadingState());

    if (isVideo) {
      emit(VideoBackgroundAssetState(assetPath: path));
    } else {
      emit(PictureBackgroundAssetState(assetPath: path));
    }
  }

  // Set specific network resource
  void setNetworkResource(String url, bool isVideo) {
    currentNetworkUrl = url;
    fromNetwork = true;
    isPicture = !isVideo;
    emit(BackgroundLoadingState());

    if (isVideo) {
      emit(VideoBackgroundNetworkState(networkUrl: url));
    } else {
      emit(PictureBackgroundNetworkState(networkUrl: url));
    }
  }

  // Legacy toggle method for backward compatibility
  void toggle() {
    toggleMediaType();
  }
}
