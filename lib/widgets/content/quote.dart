// lib/widgets/content/quote.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/language_cubit/language_cubit.dart';
import '../../services/google_sheet_service.dart';
import '../../languages/app_language.dart';
import 'package:intl/intl.dart';

class QuoteText extends StatefulWidget {
  const QuoteText({super.key});

  @override
  State<QuoteText> createState() => _QuoteTextState();
}

class _QuoteTextState extends State<QuoteText> {
  Map<String, String>? _currentQuote;
  bool _isLoading = true;
  bool _hasNetworkData = false;

  // Language-specific fonts for quotes
  final Map<String, TextStyle> _languageFonts = const {
    'English': TextStyle(
      fontFamily: 'StoryScript',
      fontSize: 18,
      fontStyle: FontStyle.italic,
      color: Colors.white70,
      height: 1.4,
      letterSpacing: 0.5,
    ),
    'Arabic': TextStyle(
      fontFamily: 'PlaypenSansArabic',
      fontSize: 19,
      fontStyle: FontStyle.normal,
      color: Colors.white70,
      height: 1.5,
      letterSpacing: 0.3,
    ),
    'Italian': TextStyle(
      fontFamily: 'Shrikhand',
      fontSize: 17,
      fontStyle: FontStyle.italic,
      color: Colors.white70,
      height: 1.4,
      letterSpacing: 0.4,
    ),
    'Greek': TextStyle(
      fontFamily: 'Mansalva',
      fontSize: 18,
      fontStyle: FontStyle.normal,
      color: Colors.white70,
      height: 1.4,
      letterSpacing: 0.2,
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadTodaysQuote();
  }

  Future<void> _loadTodaysQuote() async {
    try {
      // Get today's date in Cairo timezone
      final cairoTime = DateTime.now().toUtc().add(const Duration(hours: 2));
      final today = DateFormat('yyyy-MM-dd').format(cairoTime);

      // Fetch quotes from Google Sheets
      final quotes = await fetchSheetByGid('0'); // GID for quotes sheet

      // Find today's quote
      final todaysQuote = quotes
          .where((quote) => quote['Date'] == today)
          .toList();

      if (mounted) {
        setState(() {
          if (todaysQuote.isNotEmpty) {
            _currentQuote = todaysQuote.first;
            _hasNetworkData = true;
          } else {
            _currentQuote = null;
            _hasNetworkData = false;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentQuote = null;
          _hasNetworkData = false;
          _isLoading = false;
        });
      }
    }
  }

  String _getQuoteForLanguage(String language) {
    if (_currentQuote == null) {
      // Return default quote
      switch (language) {
        case 'English':
          return AppLanguage.defaultQuote.english;
        case 'Arabic':
          return AppLanguage.defaultQuote.arabic;
        case 'Italian':
          return AppLanguage.defaultQuote.italian;
        case 'Greek':
          return AppLanguage.defaultQuote.greek;
        default:
          return AppLanguage.defaultQuote.english;
      }
    }

    // Return quote from Google Sheets
    switch (language) {
      case 'English':
        return _currentQuote!['English Quote'] ??
            AppLanguage.defaultQuote.english;
      case 'Arabic':
        return _currentQuote!['Arabic Quote'] ??
            AppLanguage.defaultQuote.arabic;
      case 'Italian':
        return _currentQuote!['Italian Quote'] ??
            AppLanguage.defaultQuote.italian;
      case 'Greek':
        return _currentQuote!['Greek Quote'] ?? AppLanguage.defaultQuote.greek;
      default:
        return _currentQuote!['English Quote'] ??
            AppLanguage.defaultQuote.english;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
          ),
        ),
      );
    }

    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        final languageCubit = context.read<LanguageCubit>();
        final currentLanguage = languageCubit.currentLanguage;
        final quote = _getQuoteForLanguage(currentLanguage);
        final textStyle =
            _languageFonts[currentLanguage] ?? _languageFonts['English']!;
        final isRTL = currentLanguage == 'Arabic';

        // Responsive font sizing
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 600;
        final isMediumScreen = screenWidth >= 600 && screenWidth < 1024;

        final responsiveFontSize = isSmallScreen
            ? textStyle.fontSize! * 0.9
            : isMediumScreen
            ? textStyle.fontSize! * 0.95
            : textStyle.fontSize!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Text(
                quote,
                style: textStyle.copyWith(fontSize: responsiveFontSize),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Data source indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _hasNetworkData ? Icons.cloud_done : Icons.cloud_off,
                    size: 12,
                    color: _hasNetworkData ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _hasNetworkData ? 'Live' : 'Offline',
                    style: TextStyle(
                      fontSize: 10,
                      color: _hasNetworkData ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
