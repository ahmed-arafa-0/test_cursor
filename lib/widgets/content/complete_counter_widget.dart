import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../languages/app_language.dart';
import '../../cubits/countdown_cubit/countdown_cubit.dart';
import '../../cubits/language_cubit/language_cubit.dart';
import '../../cubits/content_cubit/content_cubit.dart';
import '../../utils/font_manager.dart';
import '../celebration/birthday_celebration.dart';

class CompleteCounterWidget extends StatefulWidget {
  const CompleteCounterWidget({super.key});

  @override
  State<CompleteCounterWidget> createState() => _CompleteCounterWidgetState();
}

class _CompleteCounterWidgetState extends State<CompleteCounterWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for final countdown
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Scale animation for number changes
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _triggerScaleAnimation() {
    _scaleController.forward().then((_) => _scaleController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isLandscape = screenSize.width > screenSize.height;

    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, languageState) {
        final language = context.read<LanguageCubit>().currentLanguage;
        final isRTL = FontManager.isRTL(language);

        return Directionality(
          textDirection: FontManager.getTextDirection(language),
          child: BlocBuilder<CountdownCubit, CountdownState>(
            builder: (context, countdownState) {
              // 🎉 BIRTHDAY CELEBRATION MODE! 🎉
              if (countdownState is CountdownCelebration) {
                return Stack(
                  children: [
                    // Birthday celebration message
                    Center(
                      child: _buildCelebrationMessage(
                        countdownState,
                        language,
                        screenWidth,
                        isRTL,
                      ),
                    ),
                    // 🎊 CONTINUOUS CELEBRATION ANIMATION - NEVER STOPS!
                    BirthdyCelebration(isActive: countdownState.isActive),
                  ],
                );
              }
              // Handle other countdown states normally...
              else if (countdownState is CountdownFinished) {
                return _buildBirthdayMessage(language, screenWidth, isRTL);
              } else if (countdownState is CountdownFinalSeconds) {
                _startPulseAnimation();
                return _buildFinalCountdown(
                  countdownState,
                  language,
                  screenWidth,
                  isRTL,
                );
              } else if (countdownState is CountdownTicking) {
                _stopPulseAnimation();
                return _buildMainCounter(
                  countdownState,
                  language,
                  screenWidth,
                  isLandscape,
                  isRTL,
                );
              } else if (countdownState is CountdownError) {
                return _buildErrorState(
                  countdownState,
                  language,
                  screenWidth,
                  isRTL,
                );
              } else {
                return _buildLoadingState(language, screenWidth, isRTL);
              }
            },
          ),
        );
      },
    );
  }

  // 🎉 ADD THIS NEW METHOD for celebration message display
  Widget _buildCelebrationMessage(
    CountdownCelebration state,
    String language,
    double screenWidth,
    bool isRTL,
  ) {
    final fontSize = FontManager.getResponsiveFontSize(
      screenWidth: screenWidth,
      baseFontSize: screenWidth < 600 ? 24 : 32,
    );

    return Container(
      constraints: BoxConstraints(
        maxWidth: screenWidth > 800 ? 700 : screenWidth * 0.9,
        minHeight: 400,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth < 400 ? 16 : 32,
        vertical: 60,
      ),
      padding: EdgeInsets.all(screenWidth < 400 ? 24 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.withOpacity(0.3),
            Colors.purple.withOpacity(0.3),
            Colors.orange.withOpacity(0.3),
            Colors.yellow.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.yellow.withOpacity(0.2),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✨ GLOWING BIRTHDAY MESSAGE
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Text(
              state.birthdayMessage,
              style:
                  FontManager.applyWebOptimizations(
                    FontManager.getTitleStyle(
                      language: language,
                      fontSize: fontSize,
                      color: Colors.white,
                    ),
                  ).copyWith(
                    // ✨ MAGICAL GLOWING EFFECT
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.yellow.withOpacity(0.9),
                        offset: const Offset(0, 0),
                      ),
                      Shadow(
                        blurRadius: 20,
                        color: Colors.pink.withOpacity(0.7),
                        offset: const Offset(2, 2),
                      ),
                      Shadow(
                        blurRadius: 30,
                        color: Colors.purple.withOpacity(0.5),
                        offset: const Offset(-2, -2),
                      ),
                      Shadow(
                        blurRadius: 40,
                        color: Colors.orange.withOpacity(0.4),
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
              textAlign: TextAlign.center,
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            ),
          ),

          const SizedBox(height: 30),

          // 🎊 CELEBRATION STATUS INFO
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Main celebration status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🎊', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      'CELEBRATION MODE ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('🎊', style: TextStyle(fontSize: 24)),
                  ],
                ),

                const SizedBox(height: 8),

                // Celebration details
                Text(
                  '✨ Confetti & Memories Falling Continuously ✨',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Never stops message
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '💖 This celebration never ends! 💖',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 📅 CELEBRATION START TIME
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, color: Colors.white60, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Celebration started: ${_formatCelebrationTime(state.celebrationStart)}',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ♈ SIGNATURE
          Align(
            alignment: isRTL ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '♈ AR',
                style: FontManager.getSignatureStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🕒 ADD THIS HELPER METHOD for formatting celebration time
  String _formatCelebrationTime(DateTime celebrationStart) {
    final now = DateTime.now();
    final duration = now.difference(celebrationStart);

    if (duration.inMinutes < 1) {
      return 'Just now!';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'} ago';
    } else if (duration.inDays < 1) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'} ago';
    }
  }

  Widget _buildMainCounter(
    CountdownTicking state,
    String language,
    double screenWidth,
    bool isLandscape,
    bool isRTL,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: screenWidth > 800 ? 700 : screenWidth * 0.9,
        minHeight: 300,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth < 400 ? 16 : 32,
        vertical: 16,
      ),
      padding: EdgeInsets.all(screenWidth < 400 ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          _buildTitle(language, screenWidth, isRTL),

          SizedBox(height: screenWidth < 400 ? 20 : 30),

          // Main Counter Display
          _buildCounterDisplay(
            state,
            language,
            screenWidth,
            isLandscape,
            isRTL,
          ),

          SizedBox(height: screenWidth < 400 ? 20 : 30),

          // Quote
          _buildQuote(language, screenWidth, isRTL),

          SizedBox(height: screenWidth < 400 ? 16 : 20),

          // Signature
          _buildSignature(screenWidth, isRTL),

          // REMOVED: Cairo Time Info - No longer displayed
        ],
      ),
    );
  }

  Widget _buildTitle(String language, double screenWidth, bool isRTL) {
    final fontSize = FontManager.getResponsiveFontSize(
      screenWidth: screenWidth,
      baseFontSize: 22,
    );

    final titleStyle = FontManager.getTitleStyle(
      language: language,
      fontSize: fontSize,
    );

    String title = AppLanguage.title.english;
    switch (language.toLowerCase()) {
      case 'arabic':
        title = AppLanguage.title.arabic;
        break;
      case 'italian':
        title = AppLanguage.title.italian;
        break;
      case 'greek':
        title = AppLanguage.title.greek;
        break;
    }

    return Text(
      title,
      style: FontManager.applyWebOptimizations(titleStyle),
      textAlign: TextAlign.center,
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCounterDisplay(
    CountdownTicking state,
    String language,
    double screenWidth,
    bool isLandscape,
    bool isRTL,
  ) {
    if (screenWidth < 400) {
      return _buildCompactCounterGrid(state, language, screenWidth, isRTL);
    } else if (isLandscape && screenWidth > 800) {
      return _buildWideCounterRow(state, language, screenWidth, isRTL);
    } else {
      return _buildStandardCounterWrap(state, language, screenWidth, isRTL);
    }
  }

  Widget _buildCompactCounterGrid(
    CountdownTicking state,
    String language,
    double screenWidth,
    bool isRTL,
  ) {
    // For RTL, we maintain the logical order but the layout will be mirrored
    final counterUnits = [
      _buildCounterUnit(
        state.days,
        _getTimeLabel('days', language),
        language,
        screenWidth,
        true,
        isRTL,
      ),
      _buildCounterUnit(
        state.hours,
        _getTimeLabel('hours', language),
        language,
        screenWidth,
        true,
        isRTL,
      ),
      _buildCounterUnit(
        state.minutes,
        _getTimeLabel('minutes', language),
        language,
        screenWidth,
        true,
        isRTL,
      ),
      _buildCounterUnit(
        state.seconds,
        _getTimeLabel('seconds', language),
        language,
        screenWidth,
        true,
        isRTL,
      ),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          children: [counterUnits[0], counterUnits[1]],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          children: [counterUnits[2], counterUnits[3]],
        ),
      ],
    );
  }

  Widget _buildWideCounterRow(
    CountdownTicking state,
    String language,
    double screenWidth,
    bool isRTL,
  ) {
    final counterUnits = [
      _buildCounterUnit(
        state.days,
        _getTimeLabel('days', language),
        language,
        screenWidth,
        false,
        isRTL,
      ),
      _buildCounterSeparator(),
      _buildCounterUnit(
        state.hours,
        _getTimeLabel('hours', language),
        language,
        screenWidth,
        false,
        isRTL,
      ),
      _buildCounterSeparator(),
      _buildCounterUnit(
        state.minutes,
        _getTimeLabel('minutes', language),
        language,
        screenWidth,
        false,
        isRTL,
      ),
      _buildCounterSeparator(),
      _buildCounterUnit(
        state.seconds,
        _getTimeLabel('seconds', language),
        language,
        screenWidth,
        false,
        isRTL,
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      children: counterUnits,
    );
  }

  Widget _buildStandardCounterWrap(
    CountdownTicking state,
    String language,
    double screenWidth,
    bool isRTL,
  ) {
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: screenWidth < 600 ? 16 : 24,
        runSpacing: 20,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          _buildCounterUnit(
            state.days,
            _getTimeLabel('days', language),
            language,
            screenWidth,
            false,
            isRTL,
          ),
          _buildCounterUnit(
            state.hours,
            _getTimeLabel('hours', language),
            language,
            screenWidth,
            false,
            isRTL,
          ),
          _buildCounterUnit(
            state.minutes,
            _getTimeLabel('minutes', language),
            language,
            screenWidth,
            false,
            isRTL,
          ),
          _buildCounterUnit(
            state.seconds,
            _getTimeLabel('seconds', language),
            language,
            screenWidth,
            false,
            isRTL,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterUnit(
    int value,
    String label,
    String language,
    double screenWidth,
    bool compact,
    bool isRTL,
  ) {
    final numberFontSize = FontManager.getResponsiveFontSize(
      screenWidth: screenWidth,
      baseFontSize: compact ? 20 : 28,
    );

    final labelFontSize = FontManager.getResponsiveFontSize(
      screenWidth: screenWidth,
      baseFontSize: compact ? 10 : 12,
    );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 12,
              vertical: compact ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(compact ? 8 : 12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Number
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                  child: Text(
                    value.toString().padLeft(2, '0'),
                    key: ValueKey('$label-$value'),
                    style: FontManager.applyWebOptimizations(
                      FontManager.getCounterStyle(
                        language: language,
                        fontSize: numberFontSize,
                      ),
                    ),
                    textDirection: isRTL
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                  ),
                ),

                const SizedBox(height: 4),

                // Label
                Text(
                  label,
                  style: FontManager.applyWebOptimizations(
                    FontManager.getCounterLabelStyle(
                      language: language,
                      fontSize: labelFontSize,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCounterSeparator() {
    return Text(
      ':',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildQuote(String language, double screenWidth, bool isRTL) {
    final fontSize = FontManager.getResponsiveFontSize(
      screenWidth: screenWidth,
      baseFontSize: 18,
      mobileScale: 0.75,
    );

    return BlocBuilder<ContentCubit, ContentState>(
      builder: (context, state) {
        String quote = 'You are amazing every single day. 🌟';

        if (state is ContentLoaded) {
          quote = context.read<ContentCubit>().getQuoteForLanguage(language);
        } else {
          // Use default quotes based on language
          switch (language.toLowerCase()) {
            case 'arabic':
              quote = AppLanguage.defaultQuote.arabic;
              break;
            case 'italian':
              quote = AppLanguage.defaultQuote.italian;
              break;
            case 'greek':
              quote = AppLanguage.defaultQuote.greek;
              break;
            default:
              quote = AppLanguage.defaultQuote.english;
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Text(
            quote,
            style: FontManager.applyWebOptimizations(
              FontManager.getQuoteStyle(language: language, fontSize: fontSize),
            ),
            textAlign: TextAlign.center,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget _buildSignature(double screenWidth, bool isRTL) {
    final fontSize = FontManager.getResponsiveFontSize(
      screenWidth: screenWidth,
      baseFontSize: 16,
      mobileScale: 0.8,
    );

    return Align(
      alignment: isRTL ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(
        '♈ AR',
        style: FontManager.applyWebOptimizations(
          FontManager.getSignatureStyle(fontSize: fontSize),
        ),
      ),
    );
  }

  Widget _buildFinalCountdown(
    CountdownFinalSeconds state,
    String language,
    double screenWidth,
    bool isRTL,
  ) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎉 FINAL COUNTDOWN! 🎉',
                  style: FontManager.getTitleStyle(
                    language: language,
                    fontSize: 24,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                ),
                const SizedBox(height: 20),
                Text(
                  state.seconds.toString(),
                  style: FontManager.getCounterStyle(
                    language: language,
                    fontSize: 64,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBirthdayMessage(
    String language,
    double screenWidth,
    bool isRTL,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.pink.withOpacity(0.3),
            Colors.orange.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🎉 HAPPY BIRTHDAY VEUOLLA! 🎂',
            style: FontManager.getTitleStyle(
              language: language,
              fontSize: 28,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: 16),
          Text(
            '✨ Today is your special day! ✨',
            style: FontManager.getQuoteStyle(
              language: language,
              fontSize: 20,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    CountdownError state,
    String language,
    double screenWidth,
    bool isRTL,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Countdown Error',
            style: FontManager.getTitleStyle(
              language: language,
              fontSize: 18,
              color: Colors.red,
            ),
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String language, double screenWidth, bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 20),
          Text(
            'Preparing countdown...',
            style: FontManager.getTitleStyle(language: language, fontSize: 16),
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  String _getTimeLabel(String unit, String language) {
    switch (unit) {
      case 'days':
        switch (language.toLowerCase()) {
          case 'arabic':
            return AppLanguage.counterDay.arabic;
          case 'italian':
            return AppLanguage.counterDay.italian;
          case 'greek':
            return AppLanguage.counterDay.greek;
          default:
            return AppLanguage.counterDay.english;
        }
      case 'hours':
        switch (language.toLowerCase()) {
          case 'arabic':
            return AppLanguage.counterHour.arabic;
          case 'italian':
            return AppLanguage.counterHour.italian;
          case 'greek':
            return AppLanguage.counterHour.greek;
          default:
            return AppLanguage.counterHour.english;
        }
      case 'minutes':
        switch (language.toLowerCase()) {
          case 'arabic':
            return AppLanguage.counterMin.arabic;
          case 'italian':
            return AppLanguage.counterMin.italian;
          case 'greek':
            return AppLanguage.counterMin.greek;
          default:
            return AppLanguage.counterMin.english;
        }
      case 'seconds':
        switch (language.toLowerCase()) {
          case 'arabic':
            return AppLanguage.counterSec.arabic;
          case 'italian':
            return AppLanguage.counterSec.italian;
          case 'greek':
            return AppLanguage.counterSec.greek;
          default:
            return AppLanguage.counterSec.english;
        }
      default:
        return unit;
    }
  }

  void _startPulseAnimation() {
    if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _stopPulseAnimation() {
    if (_pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }
}
