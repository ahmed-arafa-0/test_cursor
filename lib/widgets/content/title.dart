// lib/widgets/content/title.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/language_cubit/language_cubit.dart';

class TitleText extends StatelessWidget {
  const TitleText({super.key});

  // Localized titles
  final Map<String, String> _localizedTitles = const {
    'English': 'Counting down to Veuolla\'s Birthday 🎂',
    'Arabic': 'العد التنازلي لعيد ميلاد فيولا 🎂',
    'Italian': 'Conto alla rovescia per il compleanno di Veuolla 🎂',
    'Greek': 'Αντίστροφη μέτρηση για τα γενέθλια της Veuolla 🎂',
  };

  // Language-specific fonts for titles
  final Map<String, TextStyle> _languageFonts = const {
    'English': TextStyle(
      fontFamily: 'Pacifico',
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      letterSpacing: 1.2,
      height: 1.3,
      shadows: [
        Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(2, 2)),
      ],
    ),
    'Arabic': TextStyle(
      fontFamily: 'ArefRuqaa',
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 0.8,
      height: 1.4,
      shadows: [
        Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(2, 2)),
      ],
    ),
    'Italian': TextStyle(
      fontFamily: 'GrandHotel',
      fontSize: 23,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      letterSpacing: 1.1,
      height: 1.3,
      shadows: [
        Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(2, 2)),
      ],
    ),
    'Greek': TextStyle(
      fontFamily: 'PlaypenSans',
      fontSize: 21,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 1.0,
      height: 1.3,
      shadows: [
        Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(2, 2)),
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        final languageCubit = context.read<LanguageCubit>();
        final currentLanguage = languageCubit.currentLanguage;
        final title =
            _localizedTitles[currentLanguage] ?? _localizedTitles['English']!;
        final textStyle =
            _languageFonts[currentLanguage] ?? _languageFonts['English']!;
        final isRTL = currentLanguage == 'Arabic';

        // Responsive font sizing
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 600;
        final isMediumScreen = screenWidth >= 600 && screenWidth < 1024;

        final responsiveFontSize = isSmallScreen
            ? textStyle.fontSize! * 0.8
            : isMediumScreen
            ? textStyle.fontSize! * 0.9
            : textStyle.fontSize!;

        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Directionality(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: Text(
              title,
              style: textStyle.copyWith(fontSize: responsiveFontSize),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}
