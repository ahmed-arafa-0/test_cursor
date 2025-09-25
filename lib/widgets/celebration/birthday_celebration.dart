// FIXED file: lib/widgets/celebration/birthday_celebration.dart
// Compatible with package:web and working animations

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui;
import 'dart:math' as math;
import 'dart:js_interop';

class BirthdyCelebration extends StatefulWidget {
  final bool isActive;

  const BirthdyCelebration({super.key, required this.isActive});

  @override
  State<BirthdyCelebration> createState() => _BirthdyCelebrationState();
}

class _BirthdyCelebrationState extends State<BirthdyCelebration>
    with TickerProviderStateMixin {
  late String _celebrationViewType;
  web.HTMLDivElement? _celebrationElement;
  bool _isInitialized = false;

  // Animation controllers for Flutter-based animations
  late AnimationController _confettiController;
  late AnimationController _pngController;

  // All your PNG items
  final List<String> _pngItems = [
    'stars.png',
    'sunflower.png',
    'sea.png',
    'nails.png',
    'barbie.png',
    'bb.png',
    'cake.png',
    'music.png',
    'white_heart.png',
    'purple_heart.png',
    'mango.png',
    'excel.png',
    'ICT.png',
    'pen.png',
    'clips.png',
    'pc.png',
    'ram.png',
    'fam.png',
    'snail1.png',
    'snail2.png',
    'snail3.png',
    'celeb.png',
    'present.png',
    'fireworks.png',
  ];

  @override
  void initState() {
    super.initState();
    _celebrationViewType =
        'celebration-${DateTime.now().millisecondsSinceEpoch}';

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pngController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(BirthdyCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startCelebration();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopCelebration();
    }
  }

  void _startCelebration() {
    if (_isInitialized) return;

    _createCelebrationElement();
    _confettiController.repeat();
    _pngController.repeat();
    _isInitialized = true;
  }

  void _stopCelebration() {
    _confettiController.stop();
    _pngController.stop();
    _celebrationElement?.remove();
    _celebrationElement = null;
    _isInitialized = false;
  }

  void _createCelebrationElement() {
    try {
      // Create container
      _celebrationElement = web.HTMLDivElement();
      _celebrationElement!.style.position = 'fixed';
      _celebrationElement!.style.top = '0';
      _celebrationElement!.style.left = '0';
      _celebrationElement!.style.width = '100vw';
      _celebrationElement!.style.height = '100vh';
      _celebrationElement!.style.pointerEvents = 'none';
      _celebrationElement!.style.zIndex = '1000';
      _celebrationElement!.style.overflow = 'hidden';

      // Add celebration content using simpler approach
      _addCelebrationContent();

      // Register platform view
      ui.platformViewRegistry.registerViewFactory(
        _celebrationViewType,
        (int viewId) => _celebrationElement!,
      );
    } catch (e) {
      print('Error creating celebration element: $e');
      // Fallback to Flutter-only animations if HTML fails
      _isInitialized = true;
    }
  }

  void _addCelebrationContent() {
    // Add CSS-based confetti
    _addConfettiParticles();

    // Add falling PNG items
    _addFallingPNGs();

    // Start continuous generation
    _startContinuousAnimations();
  }

  void _addConfettiParticles() {
    final colors = ['#FF69B4', '#FFD700', '#FF1493', '#9370DB', '#40E0D0'];

    for (int i = 0; i < 50; i++) {
      final particle = web.HTMLDivElement();
      particle.style.position = 'absolute';
      particle.style.width = '8px';
      particle.style.height = '8px';
      particle.style.backgroundColor =
          colors[math.Random().nextInt(colors.length)];
      particle.style.left = '${math.Random().nextInt(100)}vw';
      particle.style.top = '-10px';
      particle.style.opacity = '0.8';
      particle.style.borderRadius = '50%';

      // Use CSS animation defined in index.html
      final duration = 3 + math.Random().nextInt(4);
      final delay = math.Random().nextInt(2);
      particle.style.animation =
          'fallAndRotate ${duration}s linear ${delay}s infinite';

      _celebrationElement!.appendChild(particle);
    }
  }

  void _addFallingPNGs() {
    for (int i = 0; i < 10; i++) {
      Future.delayed(Duration(milliseconds: i * 500), () {
        if (_celebrationElement != null && widget.isActive) {
          _createFallingPNG();
        }
      });
    }
  }

  void _createFallingPNG() {
    final random = math.Random();
    final pngItem = _pngItems[random.nextInt(_pngItems.length)];

    final pngElement = web.HTMLImageElement();
    pngElement.src = 'assets/images/icons/$pngItem';
    pngElement.style.position = 'absolute';
    pngElement.style.width = '${30 + random.nextInt(40)}px';
    pngElement.style.height = 'auto';
    pngElement.style.left = '${random.nextInt(90)}vw';
    pngElement.style.top = '-100px';
    pngElement.style.opacity = '0.8';
    pngElement.style.pointerEvents = 'none';
    pngElement.style.zIndex = '1001';

    // CSS animation with different speeds
    final speeds = ['slow', 'medium', 'fast'];
    final speed = speeds[random.nextInt(speeds.length)];
    pngElement.className = 'falling-png $speed';

    // Add to container
    _celebrationElement?.appendChild(pngElement);

    // Remove after animation
    Future.delayed(const Duration(seconds: 8), () {
      try {
        pngElement.remove();
      } catch (e) {
        // Element may already be removed
      }
    });
  }

  void _startContinuousAnimations() {
    // Create new confetti every 2 seconds
    void addMoreConfetti() {
      if (!widget.isActive || _celebrationElement == null) return;

      _addConfettiParticles();
      Future.delayed(const Duration(seconds: 2), addMoreConfetti);
    }

    // Create new PNGs every 1.5 seconds
    void addMorePNGs() {
      if (!widget.isActive || _celebrationElement == null) return;

      _createFallingPNG();
      Future.delayed(const Duration(milliseconds: 1500), addMorePNGs);
    }

    // Start continuous generation
    Future.delayed(const Duration(seconds: 2), addMoreConfetti);
    Future.delayed(const Duration(milliseconds: 1500), addMorePNGs);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // HTML-based celebration (if initialized)
        if (_isInitialized && _celebrationElement != null)
          Positioned.fill(
            child: HtmlElementView(viewType: _celebrationViewType),
          ),

        // Flutter-based backup celebration
        Positioned.fill(
          child: _FlutterCelebrationLayer(
            confettiController: _confettiController,
            pngController: _pngController,
            isActive: widget.isActive,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _stopCelebration();
    _confettiController.dispose();
    _pngController.dispose();
    super.dispose();
  }
}

// Flutter-based celebration backup
class _FlutterCelebrationLayer extends StatefulWidget {
  final AnimationController confettiController;
  final AnimationController pngController;
  final bool isActive;

  const _FlutterCelebrationLayer({
    required this.confettiController,
    required this.pngController,
    required this.isActive,
  });

  @override
  State<_FlutterCelebrationLayer> createState() =>
      _FlutterCelebrationLayerState();
}

class _FlutterCelebrationLayerState extends State<_FlutterCelebrationLayer> {
  final List<ConfettiParticle> _particles = [];
  final List<FallingPNG> _pngs = [];

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initializeParticles();
    }
  }

  void _initializeParticles() {
    // Create confetti particles
    for (int i = 0; i < 30; i++) {
      _particles.add(ConfettiParticle());
    }

    // Create falling PNGs
    final pngItems = [
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
      '🎀',
      '💫',
    ];

    for (int i = 0; i < 10; i++) {
      _pngs.add(FallingPNG(pngItems[i % pngItems.length]));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return Stack(
      children: [
        // Confetti layer
        ...List.generate(_particles.length, (index) {
          return AnimatedBuilder(
            animation: widget.confettiController,
            builder: (context, child) {
              final particle = _particles[index];
              final progress =
                  (widget.confettiController.value + particle.offset) % 1.0;

              return Positioned(
                left: particle.x * MediaQuery.of(context).size.width,
                top:
                    progress * (MediaQuery.of(context).size.height + 100) - 100,
                child: Transform.rotate(
                  angle: progress * 4 * math.pi,
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      color: particle.color,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // PNG emoji layer
        ...List.generate(_pngs.length, (index) {
          return AnimatedBuilder(
            animation: widget.pngController,
            builder: (context, child) {
              final png = _pngs[index];
              final progress = (widget.pngController.value + png.offset) % 1.0;

              return Positioned(
                left: png.x * MediaQuery.of(context).size.width,
                top:
                    progress * (MediaQuery.of(context).size.height + 100) - 100,
                child: Transform.rotate(
                  angle: progress * 2 * math.pi,
                  child: Transform.scale(
                    scale: 1.0 + (math.sin(progress * 4 * math.pi) * 0.3),
                    child: Text(
                      png.emoji,
                      style: TextStyle(
                        fontSize: png.size,
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
}

// Confetti particle class for Flutter animations
class ConfettiParticle {
  final double x;
  final double offset;
  final double size;
  final Color color;

  ConfettiParticle()
    : x = math.Random().nextDouble(),
      offset = math.Random().nextDouble(),
      size = 4 + math.Random().nextDouble() * 8,
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
    ];
    return colors[math.Random().nextInt(colors.length)];
  }
}

// Falling PNG class for Flutter animations
class FallingPNG {
  final double x;
  final double offset;
  final double size;
  final String emoji;

  FallingPNG(this.emoji)
    : x = math.Random().nextDouble(),
      offset = math.Random().nextDouble(),
      size = 20 + math.Random().nextDouble() * 20;
}
