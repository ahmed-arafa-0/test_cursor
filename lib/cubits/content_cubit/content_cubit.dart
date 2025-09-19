import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:developer';
import '../../models/data_models.dart';
import '../../services/data_service.dart';
// import '../services/data_service.dart';
// import '../models/data_models.dart';

part 'content_state.dart';

class ContentCubit extends Cubit<ContentState> {
  ContentCubit() : super(ContentInitial());

  DailyContent? _currentContent;
  DateTime _currentDate = DateTime.now();

  DailyContent? get currentContent => _currentContent;
  DateTime get currentDate => _currentDate;

  /// Load content for today or specific date
  Future<void> loadDailyContent([DateTime? date]) async {
    try {
      emit(ContentLoading());

      final targetDate = date ?? DateTime.now();
      _currentDate = targetDate;

      log('Loading content for date: ${targetDate.toString()}');

      final content = await DataService.getDailyContent(targetDate);
      _currentContent = content;

      emit(ContentLoaded(content: content));
    } catch (e, stackTrace) {
      log('Error loading daily content: $e', stackTrace: stackTrace);

      // Fallback to default content
      _currentContent = DailyContent.getDefault();
      emit(
        ContentError(
          message: 'Failed to load content: $e',
          fallbackContent: _currentContent!,
        ),
      );
    }
  }

  /// Get quote for current language
  String getQuoteForLanguage(String language) {
    if (_currentContent == null)
      return Quote.getDefault().getQuoteForLanguage(language);
    return _currentContent!.quote.getQuoteForLanguage(language);
  }

  /// Get current music track
  Music getCurrentMusic() {
    if (_currentContent == null) return Music.getDefault();
    return _currentContent!.getRandomMusic();
  }

  /// Get current picture
  Picture getCurrentPicture() {
    if (_currentContent == null) return Picture.getDefault();
    return _currentContent!.getRandomPicture();
  }

  /// Get current video
  VideoAsset getCurrentVideo() {
    if (_currentContent == null) return VideoAsset.getDefault();
    return _currentContent!.getRandomVideo();
  }

  /// Get all music for current day
  List<Music> getAllMusic() {
    if (_currentContent == null) return [Music.getDefault()];
    return _currentContent!.musicList.isNotEmpty
        ? _currentContent!.musicList
        : [Music.getDefault()];
  }

  /// Refresh current content
  Future<void> refresh() async {
    await loadDailyContent(_currentDate);
  }

  /// Initialize content (call at app startup)
  Future<void> initialize() async {
    try {
      emit(ContentInitializing());

      // Initialize data service
      await DataService.initialize();

      // Load today's content
      await loadDailyContent();
    } catch (e) {
      log('Error initializing content: $e');
      emit(
        ContentError(
          message: 'Failed to initialize: $e',
          fallbackContent: DailyContent.getDefault(),
        ),
      );
    }
  }

  /// Check if we have network content vs fallback
  bool get isUsingNetworkContent {
    if (_currentContent == null) return false;

    // Check if we're using default assets (indicates fallback)
    final quote = _currentContent!.quote;
    final defaultQuote = Quote.getDefault();

    return quote.englishQuote != defaultQuote.englishQuote;
  }

  /// Get content status info
  String getContentStatus() {
    if (state is ContentLoading || state is ContentInitializing) {
      return 'Loading content...';
    } else if (state is ContentError) {
      return 'Using offline content';
    } else if (isUsingNetworkContent) {
      return 'Live content loaded';
    } else {
      return 'Default content';
    }
  }

  /// Force reload from network
  Future<void> forceReload() async {
    DataService.clearCache();
    await refresh();
  }
}
