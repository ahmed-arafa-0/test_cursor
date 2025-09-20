// lib/widgets/background/asset_pic_bg.dart
import 'package:flutter/material.dart';

class AssetPictureBackground extends StatelessWidget {
  const AssetPictureBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: Container(
        key: const ValueKey('asset_picture'),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/default.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Add subtle overlay for better content readability
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
