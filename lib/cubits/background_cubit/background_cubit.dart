import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:developer';

part 'background_state.dart';

class BackgroundCubit extends Cubit<BackgroundCubitState> {
  BackgroundCubit() : super(BackgroundLoadingState());

  bool isPicture = true;
  bool fromNetwork = true; // CHANGED: Start with network content
  String? currentAssetPath;
  String? currentNetworkUrl;

  // Initialize with network content first (not defaults)
  void initialize() {
    emit(BackgroundLoadingState());

    // Start with network picture by default (will get content from Google Sheets)
    isPicture = true;
    fromNetwork = true;

    log('Background cubit initialized - waiting for content');

    // Don't emit a state yet - wait for content to load
  }

  // Initialize with actual content from Google Sheets
  void initializeWithContent(String pictureUrl, String videoUrl) {
    currentNetworkUrl = pictureUrl;
    fromNetwork = true;
    isPicture = true;

    log('Initializing background with content - Picture: $pictureUrl');

    // Load network picture immediately (no default first)
    emit(PictureBackgroundNetworkState(networkUrl: pictureUrl));
  }

  // Toggle between picture and video
  void toggleMediaType() {
    if (currentNetworkUrl == null) {
      // Fallback to asset toggle if no network content
      _toggleAssets();
      return;
    }

    isPicture = !isPicture;
    emit(BackgroundLoadingState());

    if (isPicture) {
      // Switch to picture
      if (fromNetwork && currentNetworkUrl != null) {
        emit(PictureBackgroundNetworkState(networkUrl: currentNetworkUrl!));
      } else if (currentAssetPath != null) {
        emit(PictureBackgroundAssetState(assetPath: currentAssetPath!));
      }
    } else {
      // Switch to video
      if (fromNetwork && currentNetworkUrl != null) {
        emit(VideoBackgroundNetworkState(networkUrl: currentNetworkUrl!));
      } else if (currentAssetPath != null) {
        emit(VideoBackgroundAssetState(assetPath: currentAssetPath!));
      }
    }
  }

  // Fallback asset toggle
  void _toggleAssets() {
    isPicture = !isPicture;
    fromNetwork = false;
    emit(BackgroundLoadingState());

    if (isPicture) {
      currentAssetPath = 'assets/images/default.jpg';
      emit(PictureBackgroundAssetState(assetPath: currentAssetPath!));
    } else {
      currentAssetPath = 'assets/videos/default.mp4';
      emit(VideoBackgroundAssetState(assetPath: currentAssetPath!));
    }
  }

  // Toggle between network and asset
  void toggleSource() {
    fromNetwork = !fromNetwork;
    emit(BackgroundLoadingState());

    if (isPicture) {
      if (fromNetwork && currentNetworkUrl != null) {
        emit(PictureBackgroundNetworkState(networkUrl: currentNetworkUrl!));
      } else {
        currentAssetPath = 'assets/images/default.jpg';
        emit(PictureBackgroundAssetState(assetPath: currentAssetPath!));
      }
    } else {
      if (fromNetwork && currentNetworkUrl != null) {
        emit(VideoBackgroundNetworkState(networkUrl: currentNetworkUrl!));
      } else {
        currentAssetPath = 'assets/videos/default.mp4';
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

  // FIXED: Set network resource with immediate load
  void setNetworkResource(String url, bool isVideo) {
    currentNetworkUrl = url;
    fromNetwork = true;
    isPicture = !isVideo;

    log('Setting network resource: $url (isVideo: $isVideo)');

    // No loading state - direct switch for smooth experience
    if (isVideo) {
      emit(VideoBackgroundNetworkState(networkUrl: url));
    } else {
      emit(PictureBackgroundNetworkState(networkUrl: url));
    }
  }

  // Update content URLs from Google Sheets
  void updateContentUrls(String pictureUrl, String videoUrl) {
    log('Updating content URLs - Picture: $pictureUrl, Video: $videoUrl');

    // Store both URLs
    if (isPicture) {
      currentNetworkUrl = pictureUrl;
      if (fromNetwork) {
        emit(PictureBackgroundNetworkState(networkUrl: pictureUrl));
      }
    } else {
      currentNetworkUrl = videoUrl;
      if (fromNetwork) {
        emit(VideoBackgroundNetworkState(networkUrl: videoUrl));
      }
    }
  }

  // Legacy toggle method for backward compatibility
  void toggle() {
    toggleMediaType();
  }
}
