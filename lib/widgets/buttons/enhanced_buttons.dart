import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/background_cubit/background_cubit.dart';
import '../../cubits/language_cubit/language_cubit.dart';

class EnhancedLanguageSwitch extends StatefulWidget {
  const EnhancedLanguageSwitch({super.key});

  @override
  State<EnhancedLanguageSwitch> createState() => _EnhancedLanguageSwitchState();
}

class _EnhancedLanguageSwitchState extends State<EnhancedLanguageSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePress() async {
    await _animationController.forward();
    await _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonSize = screenSize.shortestSide * 0.08;
    final clampedSize = buttonSize.clamp(35.0, 50.0);

    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        final languageCubit = context.read<LanguageCubit>();
        final languageFlags = {
          'English': '🇺🇸',
          'Arabic': '🇸🇦',
          'Italian': '🇮🇹',
          'Greek': '🇬🇷',
        };

        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: clampedSize,
                height: clampedSize,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: PopupMenuButton<String>(
                  offset: const Offset(0, 55),
                  color: Colors.black.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  onSelected: (language) {
                    _handlePress();
                    languageCubit.changeLanguage(language);
                  },
                  itemBuilder: (context) {
                    return languageFlags.entries.map((entry) {
                      final isSelected =
                          entry.key == languageCubit.currentLanguage;
                      return PopupMenuItem<String>(
                        value: entry.key,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isSelected
                                      ? Colors.yellow
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                entry.key,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.yellow
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.check,
                                  color: Colors.yellow,
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList();
                  },
                  child: Center(
                    child: Text(
                      languageCubit.getLanguageFlag(),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class EnhancedBackgroundSwitch extends StatefulWidget {
  const EnhancedBackgroundSwitch({super.key});

  @override
  State<EnhancedBackgroundSwitch> createState() =>
      _EnhancedBackgroundSwitchState();
}

class _EnhancedBackgroundSwitchState extends State<EnhancedBackgroundSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePress() async {
    await _animationController.forward();
    context.read<BackgroundCubit>().toggleMediaType();
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonSize = screenSize.shortestSide * 0.08;
    final clampedSize = buttonSize.clamp(35.0, 50.0);

    return BlocBuilder<BackgroundCubit, BackgroundCubitState>(
      builder: (context, state) {
        final backgroundCubit = context.read<BackgroundCubit>();
        final isVideo = !backgroundCubit.isPicture;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: clampedSize,
                  height: clampedSize,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isVideo
                          ? Colors.red.withOpacity(0.5)
                          : Colors.blue.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isVideo ? Colors.red : Colors.blue).withOpacity(
                          0.3,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: _handlePress,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isVideo ? Icons.videocam : Icons.photo_camera,
                            key: ValueKey(isVideo),
                            color: Colors.white,
                            size: clampedSize * 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class EnhancedMusicButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isVisible;

  const EnhancedMusicButton({
    super.key,
    this.onPressed,
    this.isVisible = false,
  });

  @override
  State<EnhancedMusicButton> createState() => _EnhancedMusicButtonState();
}

class _EnhancedMusicButtonState extends State<EnhancedMusicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.1, curve: Curves.easeInOut),
      ),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start pulsing animation
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonSize = screenSize.shortestSide * 0.08;
    final clampedSize = buttonSize.clamp(35.0, 50.0);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: Container(
            width: clampedSize,
            height: clampedSize,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isVisible
                    ? Colors.green.withOpacity(0.7)
                    : Colors.white.withOpacity(0.3),
                width: widget.isVisible ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isVisible
                      ? Colors.green.withOpacity(0.4)
                      : Colors.black.withOpacity(0.3),
                  blurRadius: widget.isVisible ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: widget.onPressed,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      widget.isVisible ? Icons.music_off : Icons.music_note,
                      key: ValueKey(widget.isVisible),
                      color: widget.isVisible ? Colors.green : Colors.white,
                      size: clampedSize * 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
