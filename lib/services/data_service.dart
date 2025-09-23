import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import '../models/data_models.dart';

class DataService {
  // Google Sheets Configuration - CORRECT GIDs
  static const String _spreadsheetId =
      '1mxAn5hS4bk_bX3_dwFERS_vpgnMj3dgN0bec3TRXDtA';
  static const String _gidQuotes = '0'; // Quotes sheet
  static const String _gidMusic = '191122548'; // Music sheet
  static const String _gidPictures = '27390536'; // Pictures sheet
  static const String _gidVideos = '1813209632'; // Videos sheet

  // Supabase Configuration
  static const String _supabaseUrl = 'https://twwvmidlorzkijbneeee.supabase.co';
  static const String _supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR3d3ZtaWRsb3J6a2lqYm5lZWVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcyNDU5NjUsImV4cCI6MjA3MjgyMTk2NX0.LIY19XdYwP3c3Bd7WZSMvkIREJAq1gmKasSQFqfA33g';

  // Cache for loaded data
  static final Map<String, List<Map<String, String>>> _cache = {};
  static DateTime? _lastCacheUpdate;

  /// Fetch data from Google Sheet by GID with DETAILED LOGGING
  // Replace the _fetchSheetByGid method in lib/services/data_service.dart

  static Future<List<Map<String, String>>> _fetchSheetByGid(String gid) async {
    try {
      final url =
          'https://docs.google.com/spreadsheets/d/$_spreadsheetId/export?format=csv&gid=$gid';

      log('🔍 DEBUGGING: Fetching Google Sheet data from GID: $gid');
      log('🔍 DEBUGGING: URL: $url');

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
        log('❌ Failed to fetch sheet GID $gid: ${response.statusCode}');
        return [];
      }

      final csvText = utf8.decode(response.bodyBytes);
      log('🔍 DEBUGGING: Raw CSV length: ${csvText.length} characters');
      log(
        '🔍 DEBUGGING: First 200 chars of CSV: ${csvText.length > 200 ? csvText.substring(0, 200) : csvText}',
      );

      // ENHANCED: Parse with your delimiter validation approach
      final rows = const CsvToListConverter(
        eol: '\n',
        fieldDelimiter: ',',
        textDelimiter: '"',
        shouldParseNumbers: false,
      ).convert(csvText);

      log('🔍 DEBUGGING: Total CSV rows parsed: ${rows.length}');

      if (rows.isEmpty || rows.length < 2) {
        log('❌ No data found in sheet GID: $gid');
        return [];
      }

      // Process headers
      final headers = rows.first.map((h) => h.toString().trim()).toList();
      log('🔍 DEBUGGING: Headers found: $headers');

      final dataRows = rows.skip(1).toList();
      log(
        '🔍 DEBUGGING: Data rows count (excluding header): ${dataRows.length}',
      );

      final result = <Map<String, String>>[];

      for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        final map = <String, String>{};

        // Build the row map
        for (var j = 0; j < headers.length; j++) {
          final header = headers[j];
          final value = j < row.length ? row[j].toString().trim() : '';

          // Clean the value
          String cleanValue = value
              .replaceAll(RegExp(r'^"'), '') // Remove leading quote
              .replaceAll(RegExp(r'"$'), '') // Remove trailing quote
              .replaceAll('""', '"') // Replace double quotes with single
              .trim();

          map[header] = cleanValue;
        }

        // ENHANCED VALIDATION using your delimiter approach
        if (gid == _gidQuotes) {
          // Check for your completion marker
          final delimiter = map['Quote Delimiter'] ?? '';
          final hasMarker = delimiter.contains('#QuoteFinished#');

          if (!hasMarker) {
            log(
              '⚠️ WARNING: Row ${i + 1} missing #QuoteFinished# marker - SKIPPING incomplete quote',
            );
            continue;
          }

          // Validate date
          final date = map['Date']?.trim();
          if (date == null || date.isEmpty || date == 'Date') {
            log('⚠️ WARNING: Row ${i + 1} invalid date "$date" - SKIPPING');
            continue;
          }

          // Enhanced logging for quotes
          final englishQuote = map['English Quote'] ?? '';
          final greekQuote = map['Greek Quote'] ?? '';

          log('✅ VALID QUOTE ROW ${i + 1}: Date="$date", Marker="$delimiter"');
          log(
            '   English: "${englishQuote.length > 30 ? englishQuote.substring(0, 30) + '...' : englishQuote}"',
          );
          log(
            '   Greek: "${greekQuote.length > 30 ? greekQuote.substring(0, 30) + '...' : greekQuote}"',
          );

          // Final validation - Greek quote should NOT contain suspicious content
          if (greekQuote.contains('2025-') ||
              greekQuote.contains('#QuoteFinished#')) {
            log('❌ ERROR: Greek quote contains invalid data - SKIPPING row');
            continue;
          }
        }

        // Add valid rows only
        final dateValue = map['Date']?.trim();
        if (dateValue != null && dateValue.isNotEmpty && dateValue != 'Date') {
          result.add(map);

          if (gid != _gidQuotes) {
            log('🔍 DEBUGGING Row ${i + 1}: Date="$dateValue"');
          }
        }
      }

      log('✅ Successfully fetched ${result.length} VALID rows from GID: $gid');
      return result;
    } catch (e, stackTrace) {
      log('❌ Error fetching sheet GID $gid: $e', stackTrace: stackTrace);
      return [];
    }
  }

  /// Get daily content for a specific date - ENHANCED DEBUG VERSION
  static Future<DailyContent> getDailyContent([DateTime? targetDate]) async {
    try {
      final date = targetDate ?? DateTime.now();
      final dateString = DateFormat('yyyy-MM-dd').format(date);

      log('🎯 LOADING DAILY CONTENT FOR: $dateString');

      // Fetch quotes sheet with detailed logging
      final quotesData = await _fetchSheetByGid(_gidQuotes);

      log('🔍 DEBUGGING: All quotes data received: ${quotesData.length} rows');

      // Show all dates found in quotes
      final allDates = quotesData.map((row) => row['Date']).toSet();
      log('🔍 DEBUGGING: All dates found in quotes: $allDates');

      // Filter quotes for the specific date
      final todayQuotes = quotesData.where((row) {
        final rowDate = row['Date']?.trim();
        log('🔍 DEBUGGING: Comparing "$rowDate" with "$dateString"');
        return rowDate == dateString;
      }).toList();

      log('🎯 FOUND ${todayQuotes.length} QUOTES FOR $dateString');

      // Show each quote found
      for (int i = 0; i < todayQuotes.length; i++) {
        final quote = todayQuotes[i];
        log(
          '🎯 Quote ${i + 1}: English="${quote['English Quote']}", Arabic="${quote['Arabic Quote']}"',
        );
      }

      // Parse ALL quotes for today
      List<Quote> quotes = [];
      for (int i = 0; i < todayQuotes.length; i++) {
        final row = todayQuotes[i];
        try {
          final quote = Quote.fromGoogleSheet(row);
          quotes.add(quote);
          log(
            '✅ Successfully parsed quote ${i + 1}: "${quote.englishQuote.substring(0, 30)}..."',
          );
        } catch (e) {
          log('❌ Error parsing quote ${i + 1}: $e');
          log('❌ Row data: $row');
        }
      }

      // If no quotes for today, use default
      if (quotes.isEmpty) {
        quotes.add(Quote.getDefault());
        log('⚠️ No valid quotes found for $dateString, using default');
      }

      // Quick fetch other data (without detailed logging)
      final musicData = await _fetchSheetByGid(_gidMusic);
      final picturesData = await _fetchSheetByGid(_gidPictures);
      final videosData = await _fetchSheetByGid(_gidVideos);

      final todayMusic = musicData
          .where((row) => row['Date'] == dateString)
          .toList();
      final todayPictures = picturesData
          .where((row) => row['Date'] == dateString)
          .toList();
      final todayVideos = videosData
          .where((row) => row['Date'] == dateString)
          .toList();

      // Parse other data
      List<Music> musicList = [];
      for (final row in todayMusic) {
        try {
          musicList.add(Music.fromGoogleSheet(row));
        } catch (e) {
          log('Error parsing music: $e');
        }
      }
      if (musicList.isEmpty) musicList.add(Music.getDefault());

      List<Picture> pictureList = [];
      for (final row in todayPictures) {
        try {
          pictureList.add(Picture.fromGoogleSheet(row));
        } catch (e) {
          log('Error parsing picture: $e');
        }
      }
      if (pictureList.isEmpty) pictureList.add(Picture.getDefault());

      List<VideoAsset> videoList = [];
      for (final row in todayVideos) {
        try {
          videoList.add(VideoAsset.fromGoogleSheet(row));
        } catch (e) {
          log('Error parsing video: $e');
        }
      }
      if (videoList.isEmpty) videoList.add(VideoAsset.getDefault());

      // Create daily content
      final dailyContent = DailyContent(
        date: date,
        quotes: quotes,
        musicList: musicList,
        pictureList: pictureList,
        videoList: videoList,
      );

      log(
        '🚀 FINAL RESULT: ${quotes.length} quotes, ${musicList.length} music, ${pictureList.length} pictures, ${videoList.length} videos',
      );

      return dailyContent;
    } catch (e, stackTrace) {
      log('❌ Error loading daily content: $e', stackTrace: stackTrace);
      return DailyContent.getDefault();
    }
  }

  /// Clear cache - FORCE FRESH DATA
  static void clearCache() {
    _cache.clear();
    _lastCacheUpdate = null;
    log('🔄 Cache cleared - will fetch fresh data');
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

  /// Get content for date range
  static Future<Map<String, DailyContent>> getContentRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final contentMap = <String, DailyContent>{};
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);
      contentMap[dateKey] = await getDailyContent(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return contentMap;
  }

  /// Initialize service
  static Future<void> initialize() async {
    log('Initializing DataService...');

    final hasConnection = await testConnection();
    log('Network connection: ${hasConnection ? 'Available' : 'Not available'}');

    if (hasConnection) {
      await getDailyContent();
      log('DataService initialized successfully');
    } else {
      log('DataService initialized in offline mode');
    }
  }
}
