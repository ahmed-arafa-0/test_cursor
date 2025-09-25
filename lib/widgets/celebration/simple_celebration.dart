// SIMPLE WORKING VERSION: lib/widgets/celebration/simple_celebration.dart
// This version will definitely work with pure Flutter animations

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class SimpleBirthdayCelebration extends StatefulWidget {
  final bool isActive;
  final Widget? child;

  const SimpleBirthdayCelebration({
    super.key,
    required this.isActive,
    this.child,
  });

  @override
  State<SimpleBirthdayCelebration> createState() =>
      _SimpleBirthdayCelebrationState();
}

class _SimpleBirthdayCelebrationState extends State<SimpleBirthdayCelebration>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _confettiController;
  late AnimationController _heartsController;
  late AnimationController _starsController;

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

    if (widget.isActive) {
      _startCelebration();
    }
  }

  @override
  void didUpdateWidget(SimpleBirthdayCelebration oldWidget) {
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

    // Start continuous particle generation
    _confettiTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (mounted && widget.isActive) {
        _addConfettiParticles(5);
      }
    });

    _heartTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (mounted && widget.isActive) {
        _addHeartParticles(2);
      }
    });

    _emojiTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (mounted && widget.isActive) {
        _addEmojiParticles(3);
      }
    });
  }

  void _stopCelebration() {
    _confettiController.stop();
    _heartsController.stop();
    _starsController.stop();

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

    // Add initial particles
    _addConfettiParticles(20);
    _addHeartParticles(10);
    _addStarParticles(15);
    _addEmojiParticles(8);
  }

  void _addConfettiParticles(int count) {
    for (int i = 0; i < count; i++) {
      _confetti.add(ConfettiParticle());
    }
    // Remove old particles to prevent memory issues
    if (_confetti.length > 100) {
      _confetti.removeRange(0, _confetti.length - 100);
    }
  }

  void _addHeartParticles(int count) {
    for (int i = 0; i < count; i++) {
      _hearts.add(HeartParticle());
    }
    if (_hearts.length > 50) {
      _hearts.removeRange(0, _hearts.length - 50);
    }
  }

  void _addStarParticles(int count) {
    for (int i = 0; i < count; i++) {
      _stars.add(StarParticle());
    }
    if (_stars.length > 60) {
      _stars.removeRange(0, _stars.length - 60);
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
      '🌸',
      '🦋',
      '🍰',
      '💝',
    ];

    for (int i = 0; i < count; i++) {
      final emoji =
          celebrationEmojis[math.Random().nextInt(celebrationEmojis.length)];
      _emojis.add(EmojiParticle(emoji));
    }
    if (_emojis.length > 40) {
      _emojis.removeRange(0, _emojis.length - 40);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return widget.child ?? const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background child
        if (widget.child != null) widget.child!,

        // Confetti layer
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

        // Hearts layer
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
                    math.sin(progress * 4 * math.pi) * 50,
                top: (1 - progress) * screenSize.height,
                child: Transform.rotate(
                  angle: progress * 2 * math.pi,
                  child: Opacity(
                    opacity: (1 - progress) * 0.8 + 0.2,
                    child: Text(
                      '💖',
                      style: TextStyle(
                        fontSize: particle.size,
                        shadows: [
                          Shadow(
                            color: Colors.pink.withOpacity(0.5),
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

        // Stars layer
        ...List.generate(_stars.length, (index) {
          return AnimatedBuilder(
            animation: _starsController,
            builder: (context, child) {
              final particle = _stars[index];
              final progress = (_starsController.value + particle.offset) % 1.0;

              return Positioned(
                left: particle.x * screenSize.width,
                top: particle.y * screenSize.height,
                child: Transform.scale(
                  scale: (math.sin(progress * 2 * math.pi) + 1) * 0.5 + 0.5,
                  child: Opacity(
                    opacity: (math.sin(progress * 2 * math.pi) + 1) * 0.3 + 0.4,
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

        // Emoji layer
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
      ],
    );
  }

  @override
  void dispose() {
    _stopCelebration();
    _confettiController.dispose();
    _heartsController.dispose();
    _starsController.dispose();
    super.dispose();
  }
}

// Particle classes
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
      size = 4 + math.Random().nextDouble() * 8,
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
      size = 16 + math.Random().nextDouble() * 12;
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
      size = 12 + math.Random().nextDouble() * 8;
}

class EmojiParticle {
  final double x;
  final double offset;
  final double size;
  final String emoji;

  EmojiParticle(this.emoji)
    : x = math.Random().nextDouble(),
      offset = math.Random().nextDouble(),
      size = 20 + math.Random().nextDouble() * 16;
}
