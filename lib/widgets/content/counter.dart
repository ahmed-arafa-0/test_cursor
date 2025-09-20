// lib/widgets/content/counter.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/language_cubit/language_cubit.dart';

class CounterText extends StatefulWidget {
  const CounterText({super.key});

  @override
  State<CounterText> createState() => _CounterTextState();
}

class _CounterTextState extends State<CounterText>
    with TickerProviderStateMixin {
  late Timer _timer;
  Duration _timeUntilBirthday = Duration.zero;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Birthday: September 26, 2025 at midnight Cairo time
  final DateTime _birthdayDate = DateTime(2025, 9, 26);

  // Language-specific fonts
  final Map<String, Map<String, TextStyle>> _languageFonts = {
    'English': {
      'counter': const TextStyle(
        fontFamily: 'Limelight',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(2, 2)),
        ],
      ),
      'units': const TextStyle(
        fontFamily: 'Limelight',
        fontSize: 12,
        color: Colors.white70,
        letterSpacing: 1.2,
      ),
    },
    'Arabic': {
      'counter': const TextStyle(
        fontFamily: 'Rakkas',
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(2, 2)),
        ],
      ),
      'units': const TextStyle(
        fontFamily: 'Rakkas',
        fontSize: 13,
        color: Colors.white70,
        letterSpacing: 0.8,
      ),
    },
    'Italian': {
      'counter': const TextStyle(
        fontFamily: 'Parisienne',
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(2, 2)),
        ],
      ),
      'units': const TextStyle(
        fontFamily: 'Parisienne',
        fontSize: 12,
        color: Colors.white70,
        letterSpacing: 1.0,
      ),
    },
    'Greek': {
      'counter': const TextStyle(
        fontFamily: 'SofiaSansExtraCondensed',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(2, 2)),
        ],
      ),
      'units': const TextStyle(
        fontFamily: 'SofiaSansExtraCondensed',
        fontSize: 12,
        color: Colors.white70,
        letterSpacing: 1.1,
      ),
    },
  };

  // Localized time units
  final Map<String, Map<String, String>> _localizedTimeUnits = {
    'English': {
      'days': 'Days 📅',
      'hours': 'Hours ⏰',
      'minutes': 'Minutes ⏱️',
      'seconds': 'Seconds ⏲️',
    },
    'Arabic': {
      'days': 'أيام 📅',
      'hours': 'ساعات ⏰',
      'minutes': 'دقائق ⏱️',
      'seconds': 'ثواني ⏲️',
    },
    'Italian': {
      'days': 'Giorni 📅',
      'hours': 'Ore ⏰',
      'minutes': 'Minuti ⏱️',
      'seconds': 'Secondi ⏲️',
    },
    'Greek': {
      'days': 'Μέρες 📅',
      'hours': 'Ώρες ⏰',
      'minutes': 'Λεπτά ⏱️',
      'seconds': 'Δευτερόλεπτα ⏲️',
    },
  };

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    // FIXED: Use Cairo time (UTC+2)
    final now = DateTime.now().toUtc().add(const Duration(hours: 2));
    final difference = _birthdayDate.difference(now);

    if (difference.inSeconds <= 0) {
      // Birthday reached!
      setState(() {
        _timeUntilBirthday = Duration.zero;
      });
      _timer.cancel();
      return;
    }

    // Start pulsing animation when less than 10 seconds
    if (difference.inSeconds <= 10 && difference.inSeconds > 0) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }

    setState(() {
      _timeUntilBirthday = difference;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildTimeUnit({
    required int value,
    required String label,
    required TextStyle numberStyle,
    required TextStyle labelStyle,
    required bool isRTL,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _timeUntilBirthday.inSeconds <= 10
              ? _pulseAnimation.value
              : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Directionality(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.toString().padLeft(2, '0'),
                    style: numberStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: labelStyle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        final languageCubit = context.read<LanguageCubit>();
        final currentLanguage = languageCubit.currentLanguage;

        if (_timeUntilBirthday.inSeconds <= 0) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.pink, Colors.purple, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🎉 Happy Birthday Veuolla! 🎂',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final currentFonts =
            _languageFonts[currentLanguage] ?? _languageFonts['English']!;
        final timeUnits =
            _localizedTimeUnits[currentLanguage] ??
            _localizedTimeUnits['English']!;
        final isRTL = currentLanguage == 'Arabic';

        // Responsive sizing
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 600;
        final isMediumScreen = screenWidth >= 600 && screenWidth < 1024;

        // Adjust font sizes for responsive design
        final counterFontSize = isSmallScreen
            ? 24.0
            : isMediumScreen
            ? 28.0
            : 32.0;
        final unitFontSize = isSmallScreen
            ? 10.0
            : isMediumScreen
            ? 11.0
            : 12.0;

        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: isSmallScreen ? 8 : 16,
                runSpacing: isSmallScreen ? 12 : 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildTimeUnit(
                    value: _timeUntilBirthday.inDays,
                    label: timeUnits['days']!,
                    numberStyle: currentFonts['counter']!.copyWith(
                      fontSize: counterFontSize,
                    ),
                    labelStyle: currentFonts['units']!.copyWith(
                      fontSize: unitFontSize,
                    ),
                    isRTL: isRTL,
                  ),
                  _buildTimeUnit(
                    value: _timeUntilBirthday.inHours.remainder(24),
                    label: timeUnits['hours']!,
                    numberStyle: currentFonts['counter']!.copyWith(
                      fontSize: counterFontSize,
                    ),
                    labelStyle: currentFonts['units']!.copyWith(
                      fontSize: unitFontSize,
                    ),
                    isRTL: isRTL,
                  ),
                  _buildTimeUnit(
                    value: _timeUntilBirthday.inMinutes.remainder(60),
                    label: timeUnits['minutes']!,
                    numberStyle: currentFonts['counter']!.copyWith(
                      fontSize: counterFontSize,
                    ),
                    labelStyle: currentFonts['units']!.copyWith(
                      fontSize: unitFontSize,
                    ),
                    isRTL: isRTL,
                  ),
                  _buildTimeUnit(
                    value: _timeUntilBirthday.inSeconds.remainder(60),
                    label: timeUnits['seconds']!,
                    numberStyle: currentFonts['counter']!.copyWith(
                      fontSize: counterFontSize,
                    ),
                    labelStyle: currentFonts['units']!.copyWith(
                      fontSize: unitFontSize,
                    ),
                    isRTL: isRTL,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
