// lib/cubits/background_cubit/background_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../services/google_sheet_service.dart';
import 'package:intl/intl.dart';

part 'background_state.dart';

class BackgroundCubit extends Cubit<BackgroundCubitState> {
  BackgroundCubit() : super(BackgroundLoadingState()) {
    _loadTodaysBackground();
  }

  bool _isPicture = true;
  bool _fromNetwork = false;
  String _currentImageUrl = 'assets/images/default.jpg';
  String _currentVideoUrl = 'assets/videos/default.mp4';
  bool _hasNetworkData = false;

  // Getters
  bool get isPicture => _isPicture;
  bool get fromNetwork => _fromNetwork;
  String get currentImageUrl => _currentImageUrl;
  String get currentVideoUrl => _currentVideoUrl;
  bool get hasNetworkData => _hasNetworkData;

  Future<void> _loadTodaysBackground() async {
    emit(BackgroundLoadingState());

    try {
      // Get today's date in Cairo timezone
      final cairoTime = DateTime.now().toUtc().add(const Duration(hours: 2));
      final today = DateFormat('yyyy-MM-dd').format(cairoTime);

      // Fetch pictures and videos from Google Sheets
      final pictures = await fetchSheetByGid('27390536'); // GID for pictures
      final videos = await fetchSheetByGid('1813209632'); // GID for videos

      // Find today's assets
      final todaysPictures = pictures
          .where((pic) => pic['Date'] == today)
          .toList();
      final todaysVideos = videos.where((vid) => vid['Date'] == today).toList();

      // Update URLs if we have network data
      if (todaysPictures.isNotEmpty) {
        _currentImageUrl =
            todaysPictures.first['URL'] ?? 'assets/images/default.jpg';
        _hasNetworkData = true;
        _fromNetwork = true;
      } else {
        _currentImageUrl = 'assets/images/default.jpg';
        _fromNetwork = false;
      }

      if (todaysVideos.isNotEmpty) {
        _currentVideoUrl =
            todaysVideos.first['URL'] ?? 'assets/videos/default.mp4';
      } else {
        _currentVideoUrl = 'assets/videos/default.mp4';
      }

      // Emit appropriate state
      if (_isPicture) {
        if (_fromNetwork && _hasNetworkData) {
          emit(PictureBackgroundNetworkState());
        } else {
          emit(PictureBackgroundAssetState());
        }
      } else {
        if (_fromNetwork && _hasNetworkData) {
          emit(VideoBackgroundNetworkState());
        } else {
          emit(VideoBackgroundAssetState());
        }
      }
    } catch (e) {
      // Fallback to defaults
      _currentImageUrl = 'assets/images/default.jpg';
      _currentVideoUrl = 'assets/videos/default.mp4';
      _hasNetworkData = false;
      _fromNetwork = false;

      emit(
        _isPicture
            ? PictureBackgroundAssetState()
            : VideoBackgroundAssetState(),
      );
    }
  }

  // Fixed method name to match your existing code
  void toggle() {
    _isPicture = !_isPicture;
    emit(BackgroundLoadingState());

    // Brief loading state for smooth transition
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_isPicture) {
        if (_fromNetwork && _hasNetworkData) {
          emit(PictureBackgroundNetworkState());
        } else {
          emit(PictureBackgroundAssetState());
        }
      } else {
        if (_fromNetwork && _hasNetworkData) {
          emit(VideoBackgroundNetworkState());
        } else {
          emit(VideoBackgroundAssetState());
        }
      }
    });
  }

  // Added method to match your existing code
  void toggleMediaType() {
    toggle(); // Just calls the existing toggle method
  }

  void forceReload() {
    _loadTodaysBackground();
  }
}
