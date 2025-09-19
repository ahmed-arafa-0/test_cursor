// Google Sheets Configuration
const String spreadsheetId = '1mxAn5hS4bk_bX3_dwFERS_vpgnMj3dgN0bec3TRXDtA';
const String gidQuotes = '0';
const String gidMusic = '191122548';
const String gidPictures = '27390536';
const String gidVideos = '1813209632';
const String gidSettings = '1277996291'; // Not used but kept for reference

// Supabase Configuration (UPDATED)
const String supabaseProjectUrl = 'https://twwvmidlorzkijbneeee.supabase.co';
const String supabaseApiKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR3d3ZtaWRsb3J6a2lqYm5lZWVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcyNDU5NjUsImV4cCI6MjA3MjgyMTk2NX0.LIY19XdYwP3c3Bd7WZSMvkIREJAq1gmKasSQFqfA33g';

// Supabase Storage Paths
const String supabaseImagesPath = 'assets/images/';
const String supabasseMusicPath = 'assets/music/';
const String supabaseVideosPath = 'assets/videos/';

// Default Asset Paths (Fallback)
const String defaultImagePath = 'assets/images/default.jpg';
const String defaultVideoPath = 'assets/videos/default.mp4';
const String defaultMusicPath = 'assets/music/default.mp3';

// Application Configuration
const String appName = 'Veuolla Birthday Countdown';
const String appVersion = '1.0.0';

// Target Date Configuration (Cairo Timezone +2)
const int birthdayYear = 2025;
const int birthdayMonth = 9;
const int birthdayDay = 26;
const int cairoTimezoneOffset = 2; // +2 hours from UTC

// Cache Configuration
const int cacheValidityMinutes = 5;
const int maxRetryAttempts = 3;
const int requestTimeoutSeconds = 10;

// UI Configuration
const double mobileBreakpoint = 600.0;
const double tabletBreakpoint = 1024.0;
const double maxContentWidth = 800.0;

// Animation Durations (in milliseconds)
const int fastAnimationMs = 200;
const int mediumAnimationMs = 400;
const int slowAnimationMs = 800;

// Default Content
class DefaultContent {
  // Default Quotes
  static const Map<String, String> defaultQuotes = {
    'english': 'You are amazing every single day. 🌟',
    'arabic': 'أنتِ رائعة في كل يوم. 🌟',
    'italian': 'Sei fantastica ogni giorno. 🌟',
    'greek': 'Είσαι υπέροχη κάθε μέρα. 🌟',
  };

  // Default Music Info
  static const Map<String, String> defaultMusic = {
    'title': 'Birthday Melody 🎵',
    'artist': 'Celebration Orchestra 🎻',
    'duration': '3:45',
  };

  // Language Flags
  static const Map<String, String> languageFlags = {
    'English': '🇺🇸',
    'Arabic': '🇸🇦',
    'Italian': '🇮🇹',
    'Greek': '🇬🇷',
  };
}

// Firebase Hosting Configuration (will be used later)
class FirebaseConfig {
  static const String projectName = 'veuolla-birthday';
  static const String hostingUrl = 'https://veuolla-birthday.web.app';
  // Will be configured when setting up Firebase
}
