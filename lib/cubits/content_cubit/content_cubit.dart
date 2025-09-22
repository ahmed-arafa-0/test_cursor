import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:developer';
import '../../models/data_models.dart';
import '../../services/data_service.dart';

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

  /// Get quote for current language (randomized from all quotes for today)
  String getQuoteForLanguage(String language) {
    if (_currentContent == null)
      return Quote.getDefault().getQuoteForLanguage(language);
    return _currentContent!.getQuoteForLanguage(
      language,
    ); // This now randomizes
  }

  /// Get current music track
  Music getCurrentMusic() {
    if (_currentContent == null) return Music.getDefault();
    return _currentContent!.getRandomMusic();
  }

  /// Get current picture - FIXED to not load default first
  Picture getCurrentPicture() {
    if (_currentContent == null) return Picture.getDefault();

    // If we have pictures for today, use them. Otherwise use default.
    if (_currentContent!.pictureList.isNotEmpty) {
      // Check if the first item is a default (from assets)
      final firstPicture = _currentContent!.pictureList.first;
      if (firstPicture.url.startsWith('assets/')) {
        // Skip defaults and get actual content if available
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

  /// Get current video - FIXED to not load default first
  VideoAsset getCurrentVideo() {
    if (_currentContent == null) return VideoAsset.getDefault();

    // If we have videos for today, use them. Otherwise use default.
    if (_currentContent!.videoList.isNotEmpty) {
      // Check if the first item is a default (from assets)
      final firstVideo = _currentContent!.videoList.first;
      if (firstVideo.url.startsWith('assets/')) {
        // Skip defaults and get actual content if available
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

  /// Refresh current content (will re-randomize quotes)
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

    // Check if we have any non-default content
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

  /// Get random quote that changes on each call
  String getRandomQuoteForLanguage(String language) {
    if (_currentContent == null || _currentContent!.quotes.isEmpty) {
      return Quote.getDefault().getQuoteForLanguage(language);
    }

    // Use current timestamp + random factor for better randomization
    final randomSeed =
        DateTime.now().millisecondsSinceEpoch + DateTime.now().microsecond;
    final index = randomSeed % _currentContent!.quotes.length;
    return _currentContent!.quotes[index].getQuoteForLanguage(language);
  }
}
