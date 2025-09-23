import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:developer';
import 'dart:math' hide log;
import '../../models/data_models.dart';
import '../../services/data_service.dart';

part 'content_state.dart';

class ContentCubit extends Cubit<ContentState> {
  ContentCubit() : super(ContentInitial());

  DailyContent? _currentContent;
  DateTime _currentDate = DateTime.now();
  int _lastQuoteIndex = -1; // Track last shown quote to avoid repetition

  // FIXED: Cache the current quote instead of selecting new one every time
  String? _cachedQuote;
  String? _cachedLanguage;

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

      log(
        'Loaded ${content.quotes.length} quotes, ${content.musicList.length} music, ${content.pictureList.length} pictures, ${content.videoList.length} videos',
      );

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

  /// Get quote for current language - FIXED: Better randomization
  /// Get quote for current language - FIXED: Cached version
  String getQuoteForLanguage(String language) {
    // Return cached quote if language hasn't changed
    if (_cachedQuote != null && _cachedLanguage == language) {
      return _cachedQuote!;
    }

    if (_currentContent == null || _currentContent!.quotes.isEmpty) {
      _cachedQuote = Quote.getDefault().getQuoteForLanguage(language);
      _cachedLanguage = language;
      return _cachedQuote!;
    }

    // If only one quote, cache and return it
    if (_currentContent!.quotes.length == 1) {
      _cachedQuote = _currentContent!.quotes.first.getQuoteForLanguage(
        language,
      );
      _cachedLanguage = language;
      return _cachedQuote!;
    }

    // Multiple quotes: ensure we don't repeat the same quote
    int newIndex;
    do {
      newIndex = Random().nextInt(_currentContent!.quotes.length);
    } while (newIndex == _lastQuoteIndex && _currentContent!.quotes.length > 1);

    _lastQuoteIndex = newIndex;

    final selectedQuote = _currentContent!.quotes[newIndex];
    _cachedQuote = selectedQuote.getQuoteForLanguage(language);
    _cachedLanguage = language;

    log(
      '🎯 Selected quote ${newIndex + 1}/${_currentContent!.quotes.length}: "${selectedQuote.englishQuote.substring(0, min(30, selectedQuote.englishQuote.length))}..."',
    );

    return _cachedQuote!;
  }

  /// Get current music track
  Music getCurrentMusic() {
    if (_currentContent == null) return Music.getDefault();
    return _currentContent!.getRandomMusic();
  }

  /// Get current picture
  Picture getCurrentPicture() {
    if (_currentContent == null) return Picture.getDefault();

    if (_currentContent!.pictureList.isNotEmpty) {
      final firstPicture = _currentContent!.pictureList.first;
      if (firstPicture.url.startsWith('assets/')) {
        final nonDefaultPictures = _currentContent!.pictureList
            .where((pic) => !pic.url.startsWith('assets/'))
            .toList();
        if (nonDefaultPictures.isNotEmpty) {
          final index =
              DateTime.now().millisecondsSinceEpoch % nonDefaultPictures.length;
          return nonDefaultPictures[index];
        }
      }
    }

    return _currentContent!.getRandomPicture();
  }

  /// Get current video
  VideoAsset getCurrentVideo() {
    if (_currentContent == null) return VideoAsset.getDefault();

    if (_currentContent!.videoList.isNotEmpty) {
      final firstVideo = _currentContent!.videoList.first;
      if (firstVideo.url.startsWith('assets/')) {
        final nonDefaultVideos = _currentContent!.videoList
            .where((vid) => !vid.url.startsWith('assets/'))
            .toList();
        if (nonDefaultVideos.isNotEmpty) {
          final index =
              DateTime.now().millisecondsSinceEpoch % nonDefaultVideos.length;
          return nonDefaultVideos[index];
        }
      }
    }

    return _currentContent!.getRandomVideo();
  }

  /// Get all music for current day
  List<Music> getAllMusic() {
    if (_currentContent == null) return [Music.getDefault()];
    return _currentContent!.musicList.isNotEmpty
        ? _currentContent!.musicList
        : [Music.getDefault()];
  }

  /// Get all quotes for current day
  List<Quote> getAllQuotes() {
    if (_currentContent == null) return [Quote.getDefault()];
    return _currentContent!.quotes.isNotEmpty
        ? _currentContent!.quotes
        : [Quote.getDefault()];
  }

  /// Refresh current content - ENHANCED: Clear cache and force reload
  Future<void> refresh() async {
    log('🔄 REFRESHING CONTENT: Clearing cache and reloading...');

    // Clear the cache to force fresh data
    DataService.clearCache();

    // Reset quote cache and index
    _cachedQuote = null;
    _cachedLanguage = null;
    _lastQuoteIndex = -1;

    // Reload content
    await loadDailyContent(_currentDate);

    log('🔄 REFRESH COMPLETE');
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

    final hasNetworkQuotes = _currentContent!.quotes.any(
      (quote) => quote.englishQuote != Quote.getDefault().englishQuote,
    );

    final hasNetworkPictures = _currentContent!.pictureList.any(
      (pic) => !pic.url.startsWith('assets/'),
    );

    final hasNetworkVideos = _currentContent!.videoList.any(
      (vid) => !vid.url.startsWith('assets/'),
    );

    final hasNetworkMusic = _currentContent!.musicList.any(
      (music) => !music.url.startsWith('assets/'),
    );

    return hasNetworkQuotes ||
        hasNetworkPictures ||
        hasNetworkVideos ||
        hasNetworkMusic;
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

  /// Get random quote that changes on each call - ENHANCED
  String getRandomQuoteForLanguage(String language) {
    if (_currentContent == null || _currentContent!.quotes.isEmpty) {
      return Quote.getDefault().getQuoteForLanguage(language);
    }

    // Always get a different quote if possible
    return getQuoteForLanguage(language);
  }

  /// Force get a new quote (for refresh button)
  String getNewQuoteForLanguage(String language) {
    log('🎯 GETTING NEW QUOTE FOR LANGUAGE: $language');

    // Clear cache to force new selection
    _cachedQuote = null;
    _cachedLanguage = null;

    return getQuoteForLanguage(language);
  }
}
