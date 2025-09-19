import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../cubits/language_cubit/language_cubit.dart';
import '../../cubits/countdown_cubit/countdown_cubit.dart';
import '../../cubits/language_cubit/language_cubit.dart';
import '../../cubits/content_cubit/content_cubit.dart';
import '../../utils/font_manager.dart';
import '../../languages/app_language.dart';

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

        return BlocBuilder<CountdownCubit, CountdownState>(
          builder: (context, countdownState) {
            // Handle different countdown states
            if (countdownState is CountdownFinished) {
              return _buildBirthdayMessage(language, screenWidth);
            } else if (countdownState is CountdownFinalSeconds) {
              _startPulseAnimation();
              return _buildFinalCountdown(
                countdownState,
                language,
                screenWidth,
              );
            } else if (countdownState is CountdownTicking) {
              _stopPulseAnimation();
              return _buildMainCounter(
                countdownState,
                language,
                screenWidth,
                isLandscape,
              );
            } else if (countdownState is CountdownError) {
              return _buildErrorState(countdownState, language, screenWidth);
            } else {
              return _buildLoadingState(language, screenWidth);
            }
          },
        );
      },
    );
  }

  Widget _buildMainCounter(
    CountdownTicking state,
    String language,
    double screenWidth,
    bool isLandscape,
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
          _buildTitle(language, screenWidth),

          SizedBox(height: screenWidth < 400 ? 20 : 30),

          // Main Counter Display
          _buildCounterDisplay(state, language, screenWidth, isLandscape),

          SizedBox(height: screenWidth < 400 ? 20 : 30),

          // Quote
          _buildQuote(language, screenWidth),

          SizedBox(height: screenWidth < 400 ? 16 : 20),

          // Signature
          _buildSignature(screenWidth),

          SizedBox(height: screenWidth < 400 ? 8 : 12),

          // Cairo Time Info
          _buildTimeInfo(state, language, screenWidth),
        ],
      ),
    );
  }

  Widget _buildTitle(String language, double screenWidth) {
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

    return Directionality(
      textDirection: FontManager.getTextDirection(language),
      child: Text(
        title,
        style: FontManager.applyWebOptimizations(titleStyle),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCounterDisplay(
    CountdownTicking state,
    String language,
    double screenWidth,
    bool isLandscape,
  ) {
    if (screenWidth < 400) {
      return _buildCompactCounterGrid(state, language, screenWidth);
    } else if (isLandscape && screenWidth > 800) {
      return _buildWideCounterRow(state, language, screenWidth);
    } else {
      return _buildStandardCounterWrap(state, language, screenWidth);
    }
  }

  Widget _buildCompactCounterGrid(
    CountdownTicking state,
    String language,
    double screenWidth,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCounterUnit(
              state.days,
              _getTimeLabel('days', language),
              language,
              screenWidth,
              true,
            ),
            _buildCounterUnit(
              state.hours,
              _getTimeLabel('hours', language),
              language,
              screenWidth,
              true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCounterUnit(
              state.minutes,
              _getTimeLabel('minutes', language),
              language,
              screenWidth,
              true,
            ),
            _buildCounterUnit(
              state.seconds,
              _getTimeLabel('seconds', language),
              language,
              screenWidth,
              true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWideCounterRow(
    CountdownTicking state,
    String language,
    double screenWidth,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCounterUnit(
          state.days,
          _getTimeLabel('days', language),
          language,
          screenWidth,
          false,
        ),
        _buildCounterSeparator(),
        _buildCounterUnit(
          state.hours,
          _getTimeLabel('hours', language),
          language,
          screenWidth,
          false,
        ),
        _buildCounterSeparator(),
        _buildCounterUnit(
          state.minutes,
          _getTimeLabel('minutes', language),
          language,
          screenWidth,
          false,
        ),
        _buildCounterSeparator(),
        _buildCounterUnit(
          state.seconds,
          _getTimeLabel('seconds', language),
          language,
          screenWidth,
          false,
        ),
      ],
    );
  }

  Widget _buildStandardCounterWrap(
    CountdownTicking state,
    String language,
    double screenWidth,
  ) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: screenWidth < 600 ? 16 : 24,
      runSpacing: 20,
      children: [
        _buildCounterUnit(
          state.days,
          _getTimeLabel('days', language),
          language,
          screenWidth,
          false,
        ),
        _buildCounterUnit(
          state.hours,
          _getTimeLabel('hours', language),
          language,
          screenWidth,
          false,
        ),
        _buildCounterUnit(
          state.minutes,
          _getTimeLabel('minutes', language),
          language,
          screenWidth,
          false,
        ),
        _buildCounterUnit(
          state.seconds,
          _getTimeLabel('seconds', language),
          language,
          screenWidth,
          false,
        ),
      ],
    );
  }

  Widget _buildCounterUnit(
    int value,
    String label,
    String language,
    double screenWidth,
    bool compact,
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
                  ),
                ),

                const SizedBox(height: 4),

                // Label
                Directionality(
                  textDirection: FontManager.getTextDirection(language),
                  child: Text(
                    label,
                    style: FontManager.applyWebOptimizations(
                      FontManager.getCounterLabelStyle(
                        language: language,
                        fontSize: labelFontSize,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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

  Widget _buildQuote(String language, double screenWidth) {
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

        return Directionality(
          textDirection: FontManager.getTextDirection(language),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Text(
              quote,
              style: FontManager.applyWebOptimizations(
                FontManager.getQuoteStyle(
                  language: language,
                  fontSize: fontSize,
                ),
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignature(double screenWidth) {
    final fontSize = FontManager.getResponsiveFontSize(
      screenWidth: screenWidth,
      baseFontSize: 16,
      mobileScale: 0.8,
    );

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '♈ AR',
        style: FontManager.applyWebOptimizations(
          FontManager.getSignatureStyle(fontSize: fontSize),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(
    CountdownTicking state,
    String language,
    double screenWidth,
  ) {
    final fontSize = FontManager.getResponsiveFontSize(
      screenWidth: screenWidth,
      baseFontSize: 11,
      mobileScale: 0.9,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, color: Colors.white60, size: fontSize + 2),
          const SizedBox(width: 6),
          Text(
            'Cairo Time: ${state.cairoTime.hour.toString().padLeft(2, '0')}:${state.cairoTime.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.white60,
              fontSize: fontSize,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalCountdown(
    CountdownFinalSeconds state,
    String language,
    double screenWidth,
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

  Widget _buildBirthdayMessage(String language, double screenWidth) {
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
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    CountdownError state,
    String language,
    double screenWidth,
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
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String language, double screenWidth) {
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
