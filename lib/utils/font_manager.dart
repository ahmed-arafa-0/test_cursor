import 'package:flutter/material.dart';

class FontManager {
  // Font configurations for each language and component
  static const Map<String, Map<String, String>> _languageFonts = {
    'English': {
      'title': 'Pacifico',
      'counter': 'Limelight',
      'quote': 'StoryScript',
      'signature': 'MrDeHaviland',
    },
    'Arabic': {
      'title': 'ArefRuqaa',
      'counter': 'Rakkas',
      'quote': 'PlaypenSansArabic',
      'signature': 'MrDeHaviland',
    },
    'Italian': {
      'title': 'GrandHotel',
      'counter': 'Parisienne',
      'quote': 'Shrikhand',
      'signature': 'MrDeHaviland',
    },
    'Greek': {
      'title': 'PlaypenSans',
      'counter': 'SofiaSansExtraCondensed',
      'quote': 'Mansalva',
      'signature': 'MrDeHaviland',
    },
  };

  /// Get title font for specific language
  static TextStyle getTitleStyle({
    required String language,
    double fontSize = 22,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w300,
  }) {
    final fontFamily =
        _languageFonts[language]?['title'] ??
        _languageFonts['English']!['title']!;

    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: 1.3,
      letterSpacing: language == 'Arabic' ? 0.5 : 1.1,
      shadows: [
        Shadow(
          blurRadius: 4,
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(1, 1),
        ),
      ],
    );
  }

  /// Get counter/timer font for specific language
  static TextStyle getCounterStyle({
    required String language,
    double fontSize = 28,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    final fontFamily =
        _languageFonts[language]?['counter'] ??
        _languageFonts['English']!['counter']!;

    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: language == 'Arabic' ? 0.5 : 1.0,
      shadows: [
        Shadow(
          blurRadius: 8,
          color: Colors.black.withOpacity(0.8),
          offset: const Offset(2, 2),
        ),
        Shadow(
          blurRadius: 4,
          color: Colors.white.withOpacity(0.1),
          offset: const Offset(-1, -1),
        ),
      ],
    );
  }

  /// Get counter label font for specific language (Days, Hours, etc.)
  static TextStyle getCounterLabelStyle({
    required String language,
    double fontSize = 12,
    Color color = Colors.white70,
    FontWeight fontWeight = FontWeight.w300,
  }) {
    final fontFamily =
        _languageFonts[language]?['counter'] ??
        _languageFonts['English']!['counter']!;

    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: language == 'Arabic' ? 0.3 : 0.8,
    );
  }

  /// Get quote font for specific language
  static TextStyle getQuoteStyle({
    required String language,
    double fontSize = 18,
    Color color = Colors.white70,
    FontStyle fontStyle = FontStyle.italic,
  }) {
    final fontFamily =
        _languageFonts[language]?['quote'] ??
        _languageFonts['English']!['quote']!;

    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: color,
      fontStyle: fontStyle,
      height: 1.4,
      letterSpacing: language == 'Arabic' ? 0.5 : 0.5,
      shadows: [
        Shadow(
          blurRadius: 2,
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(1, 1),
        ),
      ],
    );
  }

  /// Get signature font (same for all languages)
  static TextStyle getSignatureStyle({
    double fontSize = 16,
    Color color = Colors.white60,
  }) {
    return TextStyle(
      fontFamily: 'MrDeHaviland',
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      letterSpacing: 1.2,
    );
  }

  /// Get responsive font size based on screen width
  static double getResponsiveFontSize({
    required double screenWidth,
    required double baseFontSize,
    double mobileScale = 0.8,
    double tabletScale = 0.9,
  }) {
    if (screenWidth < 400) {
      return baseFontSize * mobileScale;
    } else if (screenWidth < 600) {
      return baseFontSize * (mobileScale + 0.1);
    } else if (screenWidth < 1024) {
      return baseFontSize * tabletScale;
    } else {
      return baseFontSize;
    }
  }

  /// Check if language requires RTL layout
  static bool isRTL(String language) {
    return language.toLowerCase() == 'arabic';
  }

  /// Get text direction for language
  static TextDirection getTextDirection(String language) {
    return isRTL(language) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get font fallbacks for each language
  static List<String> getFontFallbacks(String language) {
    switch (language.toLowerCase()) {
      case 'arabic':
        return ['PlaypenSansArabic', 'ArefRuqaa', 'Rakkas', 'Arial'];
      case 'italian':
        return ['GrandHotel', 'Parisienne', 'Shrikhand', 'serif'];
      case 'greek':
        return [
          'PlaypenSans',
          'SofiaSansExtraCondensed',
          'Mansalva',
          'sans-serif',
        ];
      default:
        return ['Pacifico', 'Limelight', 'StoryScript', 'serif'];
    }
  }

  /// Get font weight adjustment for different languages
  static FontWeight adjustFontWeight(String language, FontWeight baseWeight) {
    // Arabic fonts often need lighter weight for better readability
    if (language.toLowerCase() == 'arabic') {
      if (baseWeight == FontWeight.bold) return FontWeight.w600;
      if (baseWeight == FontWeight.w600) return FontWeight.w500;
    }
    return baseWeight;
  }

  /// Get line height adjustment for different languages
  static double adjustLineHeight(String language, double baseHeight) {
    // Arabic text often needs more line spacing
    if (language.toLowerCase() == 'arabic') {
      return baseHeight + 0.2;
    }
    // Greek text with ascenders/descenders
    if (language.toLowerCase() == 'greek') {
      return baseHeight + 0.1;
    }
    return baseHeight;
  }

  /// Apply font optimizations for web rendering
  static TextStyle applyWebOptimizations(TextStyle style) {
    return style.copyWith(
      // Add text rendering optimizations for web
      decorationThickness: 0,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }
}
