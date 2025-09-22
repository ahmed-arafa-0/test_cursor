// Enhanced Quote Model with Better Parsing
class Quote {
  final DateTime date;
  final String englishQuote;
  final String arabicQuote;
  final String italianQuote;
  final String greekQuote;

  Quote({
    required this.date,
    required this.englishQuote,
    required this.arabicQuote,
    required this.italianQuote,
    required this.greekQuote,
  });

  factory Quote.fromGoogleSheet(Map<String, String> row) {
    return Quote(
      date: DateTime.parse(row['Date'] ?? ''),
      englishQuote: _cleanQuote(row['English Quote'] ?? ''),
      arabicQuote: _cleanQuote(row['Arabic Quote'] ?? ''),
      italianQuote: _cleanQuote(row['Italian Quote'] ?? ''),
      greekQuote: _cleanQuote(row['Greek Quote'] ?? ''),
    );
  }

  // IMPROVED quote cleaning for your sheet format
  static String _cleanQuote(String quote) {
    // Skip quotes that are just placeholders or empty
    if (quote.trim().isEmpty ||
        quote.trim() == 'XX' ||
        quote.trim() == 'bane' ||
        quote.trim() == 'banee' ||
        quote.trim().startsWith('όμορφος') ||
        quote.trim().startsWith('عرفة') ||
        quote.trim().length < 3) {
      return ''; // Return empty for invalid quotes
    }

    return quote
        .replaceAll('"', '') // Remove quotes
        .replaceAll('*', '') // Remove asterisks
        .replaceAll('**', '') // Remove double asterisks
        .trim(); // Remove whitespace
  }

  String getQuoteForLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return englishQuote.isNotEmpty
            ? englishQuote
            : 'You are amazing every single day. 🌟';
      case 'arabic':
        return arabicQuote.isNotEmpty
            ? arabicQuote
            : 'أنتِ رائعة في كل يوم. 🌟';
      case 'italian':
        return italianQuote.isNotEmpty
            ? italianQuote
            : 'Sei fantastica ogni giorno. 🌟';
      case 'greek':
        return greekQuote.isNotEmpty
            ? greekQuote
            : 'Είσαι υπέροχη κάθε μέρα. 🌟';
      default:
        return englishQuote.isNotEmpty
            ? englishQuote
            : 'You are amazing every single day. 🌟';
    }
  }

  // Check if quote is valid (not empty or placeholder)
  bool isValid() {
    return englishQuote.isNotEmpty ||
        arabicQuote.isNotEmpty ||
        italianQuote.isNotEmpty ||
        greekQuote.isNotEmpty;
  }

  // Default fallback quote
  static Quote getDefault() {
    return Quote(
      date: DateTime.now(),
      englishQuote: 'You are amazing every single day. 🌟',
      arabicQuote: 'أنتِ رائعة في كل يوم. 🌟',
      italianQuote: 'Sei fantastica ogni giorno. 🌟',
      greekQuote: 'Είσαι υπέροχη κάθε μέρα. 🌟',
    );
  }
}

// Enhanced Music Model
class Music {
  final DateTime date;
  final String fileName;
  final String url;
  final String songName;
  final String artistName;

  Music({
    required this.date,
    required this.fileName,
    required this.url,
    required this.songName,
    required this.artistName,
  });

  factory Music.fromGoogleSheet(Map<String, String> row) {
    return Music(
      date: DateTime.parse(row['Date'] ?? ''),
      fileName: row['Name'] ?? '',
      url: row['URL'] ?? '',
      songName: row['Song Name'] ?? '',
      artistName: row['Artist Name'] ?? '',
    );
  }

  // Default fallback music
  static Music getDefault() {
    return Music(
      date: DateTime.now(),
      fileName: 'default.mp3',
      url: 'assets/songs/default.mp3',
      songName: 'Birthday Melody 🎵',
      artistName: 'Celebration Orchestra 🎻',
    );
  }

  // Get duration estimate (you can enhance this later)
  String getDuration() {
    return '3:45'; // Default duration
  }
}

// Enhanced Picture Model
class Picture {
  final DateTime date;
  final String fileName;
  final String url;

  Picture({required this.date, required this.fileName, required this.url});

  factory Picture.fromGoogleSheet(Map<String, String> row) {
    return Picture(
      date: DateTime.parse(row['Date'] ?? ''),
      fileName: row['Name'] ?? '',
      url: row['URL'] ?? '',
    );
  }

  // Default fallback picture
  static Picture getDefault() {
    return Picture(
      date: DateTime.now(),
      fileName: 'default.jpg',
      url: 'assets/images/default.jpg',
    );
  }
}

// Enhanced Video Model
class VideoAsset {
  final DateTime date;
  final String fileName;
  final String url;

  VideoAsset({required this.date, required this.fileName, required this.url});

  factory VideoAsset.fromGoogleSheet(Map<String, String> row) {
    return VideoAsset(
      date: DateTime.parse(row['Date'] ?? ''),
      fileName: row['Name'] ?? '',
      url: row['URL'] ?? '',
    );
  }

  // Default fallback video
  static VideoAsset getDefault() {
    return VideoAsset(
      date: DateTime.now(),
      fileName: 'default.mp4',
      url: 'assets/videos/default.mp4',
    );
  }
}

// FIXED Daily Content Container - Support multiple quotes with stable selection
class DailyContent {
  final DateTime date;
  final List<Quote> quotes;
  final List<Music> musicList;
  final List<Picture> pictureList;
  final List<VideoAsset> videoList;

  // FIXED: Store selected quote to prevent changing every second
  Quote? _selectedQuote;

  DailyContent({
    required this.date,
    required this.quotes,
    required this.musicList,
    required this.pictureList,
    required this.videoList,
  });

  // FIXED: Get quote that stays the same during session
  Quote getSelectedQuote() {
    if (_selectedQuote != null) return _selectedQuote!;

    if (quotes.isEmpty) {
      _selectedQuote = Quote.getDefault();
      return _selectedQuote!;
    }

    // Filter out invalid quotes
    final validQuotes = quotes.where((quote) => quote.isValid()).toList();

    if (validQuotes.isEmpty) {
      _selectedQuote = Quote.getDefault();
      return _selectedQuote!;
    }

    // Use date-based seed for consistent selection during the day
    final dateSeed = date.year * 10000 + date.month * 100 + date.day;
    final index = dateSeed % validQuotes.length;
    _selectedQuote = validQuotes[index];

    return _selectedQuote!;
  }

  // FIXED: Get quote for specific language (stable, doesn't change)
  String getQuoteForLanguage(String language) {
    final selectedQuote = getSelectedQuote();
    return selectedQuote.getQuoteForLanguage(language);
  }

  // Get random music for the day
  Music getRandomMusic() {
    if (musicList.isEmpty) return Music.getDefault();
    final index = DateTime.now().millisecondsSinceEpoch % musicList.length;
    return musicList[index];
  }

  // Get random picture for the day
  Picture getRandomPicture() {
    if (pictureList.isEmpty) return Picture.getDefault();
    final index = DateTime.now().millisecondsSinceEpoch % pictureList.length;
    return pictureList[index];
  }

  // Get random video for the day
  VideoAsset getRandomVideo() {
    if (videoList.isEmpty) return VideoAsset.getDefault();
    final index = DateTime.now().millisecondsSinceEpoch % videoList.length;
    return videoList[index];
  }

  // Create default content for fallback
  static DailyContent getDefault() {
    return DailyContent(
      date: DateTime.now(),
      quotes: [Quote.getDefault()],
      musicList: [Music.getDefault()],
      pictureList: [Picture.getDefault()],
      videoList: [VideoAsset.getDefault()],
    );
  }
}
