// Updated file: lib/widgets/celebration/birthday_celebration.dart
// FIXED for package:web compatibility

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
    _isInitialized = true;
  }

  void _stopCelebration() {
    _celebrationElement?.remove();
    _celebrationElement = null;
    _isInitialized = false;
  }

  void _createCelebrationElement() {
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

    // Add confetti canvas
    final confettiCanvas = web.HTMLCanvasElement();
    confettiCanvas.width = web.window.innerWidth;
    confettiCanvas.height = web.window.innerHeight;
    confettiCanvas.style.position = 'absolute';
    confettiCanvas.style.top = '0';
    confettiCanvas.style.left = '0';
    confettiCanvas.style.width = '100%';
    confettiCanvas.style.height = '100%';
    confettiCanvas.style.pointerEvents = 'none';

    _celebrationElement!.appendChild(confettiCanvas);

    // Start continuous confetti
    _startConfetti(confettiCanvas);

    // Start PNG falling animation
    _startPNGFalling();

    // Register platform view
    ui.platformViewRegistry.registerViewFactory(
      _celebrationViewType,
      (int viewId) => _celebrationElement!,
    );
  }

  void _startConfetti(web.HTMLCanvasElement canvas) {
    final context = canvas.getContext('2d') as web.CanvasRenderingContext2D;
    final particles = <ConfettiParticle>[];

    // Initialize particles
    for (int i = 0; i < 100; i++) {
      particles.add(
        ConfettiParticle(canvas.width.toDouble(), canvas.height.toDouble()),
      );
    }

    void animate(num time) {
      // Clear canvas
      context.clearRect(0, 0, canvas.width, canvas.height);

      // Update and draw particles
      for (final particle in particles) {
        particle.update();
        particle.draw(context);

        // Reset particle if it goes off screen
        if (particle.y > canvas.height + 10) {
          particle.reset(canvas.width.toDouble());
        }
      }

      // Add new particles randomly
      if (math.Random().nextDouble() < 0.1) {
        particles.add(
          ConfettiParticle(canvas.width.toDouble(), canvas.height.toDouble()),
        );
      }

      // FIXED: Continue animation with proper callback type
      web.window.requestAnimationFrame(animate.toJS);
    }

    // Start the animation
    web.window.requestAnimationFrame(animate.toJS);
  }

  void _startPNGFalling() {
    // Create PNG falling animation every 2 seconds
    void createFallingPNG() {
      final random = math.Random();
      final pngItem = _pngItems[random.nextInt(_pngItems.length)];

      final pngElement = web.HTMLImageElement();
      pngElement.src = 'assets/images/icons/$pngItem';
      pngElement.style.position = 'absolute';
      pngElement.style.width = '${30 + random.nextInt(40)}px';
      pngElement.style.height = 'auto';
      pngElement.style.left = '${random.nextInt(100)}vw';
      pngElement.style.top = '-100px';
      pngElement.style.opacity = '0.8';
      pngElement.style.pointerEvents = 'none';
      pngElement.style.transform = 'rotate(${random.nextInt(360)}deg)';

      // Add CSS animation
      pngElement.style.animation =
          '''
        fallAndRotate ${4 + random.nextInt(4)}s linear forwards,
        fadeOut 1s ease-in ${3 + random.nextInt(4)}s forwards
      ''';

      _celebrationElement!.appendChild(pngElement);

      // Remove element after animation
      Future.delayed(const Duration(seconds: 8), () {
        pngElement.remove();
      });
    }

    // Create initial batch
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 400), createFallingPNG);
    }

    // Continue creating PNGs every 2 seconds
    void continuousLoop() {
      createFallingPNG();
      Future.delayed(const Duration(seconds: 2), continuousLoop);
    }

    Future.delayed(const Duration(seconds: 2), continuousLoop);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive || !_isInitialized) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: HtmlElementView(viewType: _celebrationViewType),
    );
  }

  @override
  void dispose() {
    _stopCelebration();
    super.dispose();
  }
}

// FIXED Confetti particle class for package:web
class ConfettiParticle {
  double x, y, vx, vy;
  double rotation = 0;
  double rotationSpeed;
  String color;
  double size;
  final double maxY;

  ConfettiParticle(double maxX, this.maxY)
    : x = math.Random().nextDouble() * maxX,
      y = -10,
      vx = (math.Random().nextDouble() - 0.5) * 4,
      vy = math.Random().nextDouble() * 3 + 2,
      rotationSpeed = (math.Random().nextDouble() - 0.5) * 10,
      size = math.Random().nextDouble() * 8 + 4,
      color = _getRandomColor();

  void update() {
    x += vx;
    y += vy;
    rotation += rotationSpeed;
    vy += 0.1; // Gravity
  }

  // FIXED: Draw method for package:web
  void draw(web.CanvasRenderingContext2D context) {
    context.save();
    context.translate(x, y);
    context.rotate(rotation * math.pi / 180);

    // FIXED: Convert string to JSAny for fillStyle
    context.fillStyle = color.toJS;
    context.fillRect(-size / 2, -size / 2, size, size);
    context.restore();
  }

  void reset(double maxX) {
    x = math.Random().nextDouble() * maxX;
    y = -10;
    vx = (math.Random().nextDouble() - 0.5) * 4;
    vy = math.Random().nextDouble() * 3 + 2;
    color = _getRandomColor();
  }

  static String _getRandomColor() {
    final colors = [
      '#FF69B4',
      '#FFD700',
      '#FF1493',
      '#9370DB',
      '#FF6347',
      '#40E0D0',
      '#FF8C00',
      '#DA70D6',
    ];
    return colors[math.Random().nextInt(colors.length)];
  }
}
