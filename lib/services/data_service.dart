import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import '../models/data_models.dart';

class DataService {
  // Google Sheets Configuration
  static const String _spreadsheetId =
      '1mxAn5hS4bk_bX3_dwFERS_vpgnMj3dgN0bec3TRXDtA';
  static const String _gidQuotes = '0';
  static const String _gidMusic = '191122548';
  static const String _gidPictures = '27390536';
  static const String _gidVideos = '1813209632';

  // Supabase Configuration
  static const String _supabaseUrl = 'https://twwvmidlorzkijbneeee.supabase.co';
  static const String _supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR3d3ZtaWRsb3J6a2lqYm5lZWVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcyNDU5NjUsImV4cCI6MjA3MjgyMTk2NX0.LIY19XdYwP3c3Bd7WZSMvkIREJAq1gmKasSQFqfA33g';

  // Cache for loaded data
  static final Map<String, List<Map<String, String>>> _cache = {};
  static DateTime? _lastCacheUpdate;

  /// Fetch data from Google Sheet by GID
  static Future<List<Map<String, String>>> _fetchSheetByGid(String gid) async {
    try {
      // Check cache first (valid for 5 minutes)
      final cacheKey = 'sheet_$gid';
      if (_cache.containsKey(cacheKey) &&
          _lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!).inMinutes < 5) {
        log('Using cached data for GID: $gid');
        return _cache[cacheKey]!;
      }

      final url =
          'https://docs.google.com/spreadsheets/d/$_spreadsheetId/export?format=csv&gid=$gid';

      log('Fetching Google Sheet data from GID: $gid');
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Accept': 'text/csv',
              'User-Agent': 'VeuollaBirthdayApp/1.0',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        log('Failed to fetch sheet GID $gid: ${response.statusCode}');
        return [];
      }

      final csvText = utf8.decode(response.bodyBytes);
      final rows = const CsvToListConverter(eol: '\n').convert(csvText);

      if (rows.isEmpty || rows.length < 2) {
        log('No data found in sheet GID: $gid');
        return [];
      }

      // Process headers and data
      final headers = rows.first.map((h) => h.toString().trim()).toList();
      final dataRows = rows.skip(1);

      final result = dataRows.map((row) {
        final map = <String, String>{};
        for (var i = 0; i < headers.length; i++) {
          final header = headers[i];
          final value = i < row.length ? row[i].toString().trim() : '';
          map[header] = value;
        }
        return map;
      }).toList();

      // Cache the result
      _cache[cacheKey] = result;
      _lastCacheUpdate = DateTime.now();

      log('Successfully fetched ${result.length} rows from GID: $gid');
      return result;
    } catch (e, stackTrace) {
      log('Error fetching sheet GID $gid: $e', stackTrace: stackTrace);
      return [];
    }
  }

  /// Get daily content for a specific date
  static Future<DailyContent> getDailyContent([DateTime? targetDate]) async {
    try {
      final date = targetDate ?? DateTime.now();
      final dateString = DateFormat('yyyy-MM-dd').format(date);

      log('Loading daily content for date: $dateString');

      // Fetch all sheets in parallel
      final results = await Future.wait([
        _fetchSheetByGid(_gidQuotes),
        _fetchSheetByGid(_gidMusic),
        _fetchSheetByGid(_gidPictures),
        _fetchSheetByGid(_gidVideos),
      ]);

      final quotesData = results[0];
      final musicData = results[1];
      final picturesData = results[2];
      final videosData = results[3];

      // Filter data for the specific date
      final todayQuotes = quotesData
          .where((row) => row['Date'] == dateString)
          .toList();
      final todayMusic = musicData
          .where((row) => row['Date'] == dateString)
          .toList();
      final todayPictures = picturesData
          .where((row) => row['Date'] == dateString)
          .toList();
      final todayVideos = videosData
          .where((row) => row['Date'] == dateString)
          .toList();

      // Parse quotes
      Quote quote = Quote.getDefault();
      if (todayQuotes.isNotEmpty) {
        try {
          quote = Quote.fromGoogleSheet(todayQuotes.first);
        } catch (e) {
          log('Error parsing quote: $e');
        }
      }

      // Parse music
      List<Music> musicList = [];
      for (final row in todayMusic) {
        try {
          musicList.add(Music.fromGoogleSheet(row));
        } catch (e) {
          log('Error parsing music: $e');
        }
      }
      if (musicList.isEmpty) {
        musicList.add(Music.getDefault());
      }

      // Parse pictures
      List<Picture> pictureList = [];
      for (final row in todayPictures) {
        try {
          pictureList.add(Picture.fromGoogleSheet(row));
        } catch (e) {
          log('Error parsing picture: $e');
        }
      }
      if (pictureList.isEmpty) {
        pictureList.add(Picture.getDefault());
      }

      // Parse videos
      List<VideoAsset> videoList = [];
      for (final row in todayVideos) {
        try {
          videoList.add(VideoAsset.fromGoogleSheet(row));
        } catch (e) {
          log('Error parsing video: $e');
        }
      }
      if (videoList.isEmpty) {
        videoList.add(VideoAsset.getDefault());
      }

      final dailyContent = DailyContent(
        date: date,
        quote: quote,
        musicList: musicList,
        pictureList: pictureList,
        videoList: videoList,
      );

      log(
        'Successfully loaded daily content: Quote=${quote.englishQuote.substring(0, 30)}..., Music=${musicList.length}, Pictures=${pictureList.length}, Videos=${videoList.length}',
      );

      return dailyContent;
    } catch (e, stackTrace) {
      log('Error loading daily content: $e', stackTrace: stackTrace);
      return DailyContent.getDefault();
    }
  }

  /// Test network connectivity
  static Future<bool> testConnection() async {
    try {
      final response = await http
          .head(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Verify Supabase asset accessibility
  static Future<bool> verifySupabaseAsset(String url) async {
    try {
      final response = await http
          .head(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $_supabaseKey'},
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      log('Failed to verify Supabase asset: $url - $e');
      return false;
    }
  }

  /// Clear cache (useful for testing)
  static void clearCache() {
    _cache.clear();
    _lastCacheUpdate = null;
    log('Data cache cleared');
  }

  /// Get all available dates with content
  static Future<List<DateTime>> getAvailableDates() async {
    try {
      final quotesData = await _fetchSheetByGid(_gidQuotes);
      final dates = <DateTime>[];

      for (final row in quotesData) {
        try {
          final dateStr = row['Date'];
          if (dateStr != null && dateStr.isNotEmpty) {
            final date = DateTime.parse(dateStr);
            dates.add(date);
          }
        } catch (e) {
          // Skip invalid dates
        }
      }

      dates.sort();
      return dates;
    } catch (e) {
      log('Error getting available dates: $e');
      return [];
    }
  }

  /// Get content for date range (useful for preloading)
  static Future<Map<String, DailyContent>> getContentRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final contentMap = <String, DailyContent>{};
    final currentDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);
      contentMap[dateKey] = await getDailyContent(currentDate);
      currentDate.add(const Duration(days: 1));
    }

    return contentMap;
  }

  /// Initialize service (call this at app startup)
  static Future<void> initialize() async {
    log('Initializing DataService...');

    // Test connection
    final hasConnection = await testConnection();
    log('Network connection: ${hasConnection ? 'Available' : 'Not available'}');

    if (hasConnection) {
      // Preload today's content
      await getDailyContent();
      log('DataService initialized successfully');
    } else {
      log('DataService initialized in offline mode');
    }
  }
}
