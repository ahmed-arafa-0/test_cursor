// FULLSCREEN CELEBRATION: lib/widgets/celebration/fullscreen_celebration.dart
// This goes ABOVE everything else in the main app

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class FullscreenBirthdayCelebration extends StatefulWidget {
  final bool isActive;
  final String language; // Add language parameter

  const FullscreenBirthdayCelebration({
    super.key,
    required this.isActive,
    required this.language,
  });

  @override
  State<FullscreenBirthdayCelebration> createState() =>
      _FullscreenBirthdayCelebrationState();
}

class _FullscreenBirthdayCelebrationState
    extends State<FullscreenBirthdayCelebration>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _confettiController;
  late AnimationController _heartsController;
  late AnimationController _starsController;
  late AnimationController _titleController;

  // Particle lists
  final List<ConfettiParticle> _confetti = [];
  final List<HeartParticle> _hearts = [];
  final List<StarParticle> _stars = [];
  final List<EmojiParticle> _emojis = [];

  // Timers for continuous generation
  Timer? _confettiTimer;
  Timer? _heartTimer;
  Timer? _emojiTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _confettiController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _heartsController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _starsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _titleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    if (widget.isActive) {
      _startCelebration();
    }
  }

  @override
  void didUpdateWidget(FullscreenBirthdayCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startCelebration();
      } else {
        _stopCelebration();
      }
    }
  }

  void _startCelebration() {
    // Initialize particles
    _initializeParticles();

    // Start animations
    _confettiController.repeat();
    _heartsController.repeat();
    _starsController.repeat();
    _titleController.repeat(reverse: true);

    // Start continuous particle generation
    _confettiTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted && widget.isActive) {
        _addConfettiParticles(8);
      }
    });

    _heartTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (mounted && widget.isActive) {
        _addHeartParticles(3);
      }
    });

    _emojiTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted && widget.isActive) {
        _addEmojiParticles(4);
      }
    });
  }

  void _stopCelebration() {
    _confettiController.stop();
    _heartsController.stop();
    _starsController.stop();
    _titleController.stop();

    _confettiTimer?.cancel();
    _heartTimer?.cancel();
    _emojiTimer?.cancel();

    // Clear particles
    _confetti.clear();
    _hearts.clear();
    _stars.clear();
    _emojis.clear();
  }

  void _initializeParticles() {
    _confetti.clear();
    _hearts.clear();
    _stars.clear();
    _emojis.clear();

    // Add initial particles - MORE for fullscreen
    _addConfettiParticles(40);
    _addHeartParticles(20);
    _addStarParticles(30);
    _addEmojiParticles(15);
  }

  void _addConfettiParticles(int count) {
    for (int i = 0; i < count; i++) {
      _confetti.add(ConfettiParticle());
    }
    if (_confetti.length > 200) {
      _confetti.removeRange(0, _confetti.length - 200);
    }
  }

  void _addHeartParticles(int count) {
    for (int i = 0; i < count; i++) {
      _hearts.add(HeartParticle());
    }
    if (_hearts.length > 100) {
      _hearts.removeRange(0, _hearts.length - 100);
    }
  }

  void _addStarParticles(int count) {
    for (int i = 0; i < count; i++) {
      _stars.add(StarParticle());
    }
    if (_stars.length > 120) {
      _stars.removeRange(0, _stars.length - 120);
    }
  }

  void _addEmojiParticles(int count) {
    final celebrationEmojis = [
      '🎉',
      '🎂',
      '🎈',
      '🎁',
      '⭐',
      '💖',
      '🌟',
      '✨',
      '🎊',
      '🎵',
      '🌻',
      '🦋',
      '🍰',
      '🤍',
      '🎀',
      '💫',
    ];

    for (int i = 0; i < count; i++) {
      final emoji =
          celebrationEmojis[math.Random().nextInt(celebrationEmojis.length)];
      _emojis.add(EmojiParticle(emoji));
    }
    if (_emojis.length > 80) {
      _emojis.removeRange(0, _emojis.length - 80);
    }
  }

  // 🌍 LANGUAGE SUPPORT - ADD YOUR TITLES AND SUBTITLES HERE! 🌍
  String _getTitle() {
    switch (widget.language.toLowerCase()) {
      case 'english':
        return '🎉 HAPPY BIRTHDAY VEUOLLA! 🎂'; // 👈 EDIT THIS

      case 'arabic':
        return '🎉 عيد ميلاد سعيد فيولا! 🎂'; // 👈 EDIT THIS

      case 'italian':
        return '🎉 BUON COMPLEANNO VEUOLLA! 🎂'; // 👈 EDIT THIS

      case 'greek':
        return '🎉 ΧΑΡΟΎΜΕΝΑ ΓΕΝΈΘΛΙΑ VEUOLLA! 🎂'; // 👈 EDIT THIS

      default:
        return '🎉 HAPPY BIRTHDAY VEUOLLA! 🎂';
    }
  }

  String _getSubtitle() {
    switch (widget.language.toLowerCase()) {
      case 'english':
        return '✨ Today is your special day! May all your dreams come true! ✨'; // 👈 EDIT THIS

      case 'arabic':
        return '✨ اليوم هو يومك المميز! عسى أن تتحقق كل أحلامك! ✨'; // 👈 EDIT THIS

      case 'italian':
        return '✨ Oggi è il tuo giorno speciale! Che tutti i tuoi sogni si avverino! ✨'; // 👈 EDIT THIS

      case 'greek':
        return '✨ Σήμερα είναι η ξεχωριστή σου μέρα! Ας πραγματοποιηθούν όλα σου τα όνειρα! ✨'; // 👈 EDIT THIS

      default:
        return '✨ Today is your special day! May all your dreams come true! ✨';
    }
  }

  bool _isRTL() {
    return widget.language.toLowerCase() == 'arabic';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.1), // Slight dark overlay
        child: Stack(
          children: [
            // 🎊 FULLSCREEN CONFETTI LAYER
            ...List.generate(_confetti.length, (index) {
              return AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  final particle = _confetti[index];
                  final progress =
                      (_confettiController.value + particle.offset) % 1.0;

                  return Positioned(
                    left: particle.x * screenSize.width,
                    top: progress * (screenSize.height + 100) - 100,
                    child: Transform.rotate(
                      angle: progress * 4 * math.pi + particle.rotationOffset,
                      child: Container(
                        width: particle.size,
                        height: particle.size,
                        decoration: BoxDecoration(
                          color: particle.color,
                          shape: particle.isCircle
                              ? BoxShape.circle
                              : BoxShape.rectangle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // 💖 FULLSCREEN HEARTS LAYER
            ...List.generate(_hearts.length, (index) {
              return AnimatedBuilder(
                animation: _heartsController,
                builder: (context, child) {
                  final particle = _hearts[index];
                  final progress =
                      (_heartsController.value + particle.offset) % 1.0;

                  return Positioned(
                    left:
                        particle.x * screenSize.width +
                        math.sin(progress * 4 * math.pi) * 60,
                    top: (1 - progress) * screenSize.height,
                    child: Transform.rotate(
                      angle: progress * 2 * math.pi,
                      child: Opacity(
                        opacity: (1 - progress) * 0.8 + 0.2,
                        child: Text(
                          '🤍',
                          style: TextStyle(
                            fontSize: particle.size,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 3,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // ⭐ FULLSCREEN STARS LAYER
            ...List.generate(_stars.length, (index) {
              return AnimatedBuilder(
                animation: _starsController,
                builder: (context, child) {
                  final particle = _stars[index];
                  final progress =
                      (_starsController.value + particle.offset) % 1.0;

                  return Positioned(
                    left: particle.x * screenSize.width,
                    top: particle.y * screenSize.height,
                    child: Transform.scale(
                      scale: (math.sin(progress * 2 * math.pi) + 1) * 0.5 + 0.5,
                      child: Opacity(
                        opacity:
                            (math.sin(progress * 2 * math.pi) + 1) * 0.3 + 0.4,
                        child: Text(
                          '⭐',
                          style: TextStyle(
                            fontSize: particle.size,
                            shadows: [
                              Shadow(
                                color: Colors.yellow.withOpacity(0.8),
                                blurRadius: 5,
                                offset: Offset.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // 🎉 FULLSCREEN EMOJI LAYER
            ...List.generate(_emojis.length, (index) {
              return AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  final particle = _emojis[index];
                  final progress =
                      (_confettiController.value + particle.offset) % 1.0;

                  return Positioned(
                    left: particle.x * screenSize.width,
                    top: progress * (screenSize.height + 100) - 100,
                    child: Transform.rotate(
                      angle: progress * 3 * math.pi,
                      child: Transform.scale(
                        scale: 1.0 + math.sin(progress * 6 * math.pi) * 0.3,
                        child: Text(
                          particle.emoji,
                          style: TextStyle(
                            fontSize: particle.size,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // 🎊 CENTER CELEBRATION MESSAGE 🎊
            Center(
              child: AnimatedBuilder(
                animation: _titleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_titleController.value * 0.1),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: screenSize.width * 0.9,
                        maxHeight: screenSize.height * 0.6,
                      ),
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        // gradient: LinearGradient(
                        //   colors: [
                        //     Colors.pink.withOpacity(0.4),
                        //     Colors.purple.withOpacity(0.4),
                        //     Colors.orange.withOpacity(0.4),
                        //     Colors.yellow.withOpacity(0.4),
                        //   ],
                        //   begin: Alignment.topLeft,
                        //   end: Alignment.bottomRight,
                        // ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.3),
                            blurRadius: 50,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Directionality(
                        textDirection: _isRTL()
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🎉 MAIN TITLE
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                _getTitle(), // 👈 YOUR CUSTOM TITLE HERE
                                style: TextStyle(
                                  fontSize: screenSize.width < 600 ? 20 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 15,
                                      color: Colors.yellow.withOpacity(0.9),
                                      offset: const Offset(0, 0),
                                    ),
                                    Shadow(
                                      blurRadius: 25,
                                      color: Colors.pink.withOpacity(0.7),
                                      offset: const Offset(2, 2),
                                    ),
                                    Shadow(
                                      blurRadius: 35,
                                      color: Colors.purple.withOpacity(0.5),
                                      offset: const Offset(-2, -2),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ✨ SUBTITLE
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getSubtitle(), // 👈 YOUR CUSTOM SUBTITLE HERE
                                style: TextStyle(
                                  fontSize: screenSize.width < 600 ? 16 : 20,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 3,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopCelebration();
    _confettiController.dispose();
    _heartsController.dispose();
    _starsController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}

// Particle classes (same as before but keeping for completeness)
class ConfettiParticle {
  final double x;
  final double offset;
  final double size;
  final Color color;
  final double rotationOffset;
  final bool isCircle;

  ConfettiParticle()
    : x = math.Random().nextDouble(),
      offset = math.Random().nextDouble(),
      size = 4 + math.Random().nextDouble() * 10,
      rotationOffset = math.Random().nextDouble() * 2 * math.pi,
      isCircle = math.Random().nextBool(),
      color = _getRandomColor();

  static Color _getRandomColor() {
    final colors = [
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.red,
      Colors.teal,
      Colors.cyan,
      Colors.lime,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }
}

class HeartParticle {
  final double x;
  final double offset;
  final double size;

  HeartParticle()
    : x = math.Random().nextDouble(),
      offset = math.Random().nextDouble(),
      size = 16 + math.Random().nextDouble() * 16;
}

class StarParticle {
  final double x;
  final double y;
  final double offset;
  final double size;

  StarParticle()
    : x = math.Random().nextDouble(),
      y = math.Random().nextDouble(),
      offset = math.Random().nextDouble(),
      size = 12 + math.Random().nextDouble() * 12;
}

class EmojiParticle {
  final double x;
  final double offset;
  final double size;
  final String emoji;

  EmojiParticle(this.emoji)
    : x = math.Random().nextDouble(),
      offset = math.Random().nextDouble(),
      size = 20 + math.Random().nextDouble() * 20;
}
