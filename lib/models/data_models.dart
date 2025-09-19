// Enhanced Quote Model
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

  // Clean quotes from extra quotes and asterisks
  static String _cleanQuote(String quote) {
    return quote.replaceAll('"', '').replaceAll('*', '').trim();
  }

  String getQuoteForLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return englishQuote;
      case 'arabic':
        return arabicQuote;
      case 'italian':
        return italianQuote;
      case 'greek':
        return greekQuote;
      default:
        return englishQuote;
    }
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

// Daily Content Container
class DailyContent {
  final DateTime date;
  final Quote quote;
  final List<Music> musicList;
  final List<Picture> pictureList;
  final List<VideoAsset> videoList;

  DailyContent({
    required this.date,
    required this.quote,
    required this.musicList,
    required this.pictureList,
    required this.videoList,
  });

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
      quote: Quote.getDefault(),
      musicList: [Music.getDefault()],
      pictureList: [Picture.getDefault()],
      videoList: [VideoAsset.getDefault()],
    );
  }
}
