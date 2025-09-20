// lib/widgets/content/content_box.dart
import 'package:flutter/material.dart';
import 'package:test_cursor/widgets/content/counter.dart';
import 'package:test_cursor/widgets/content/quote.dart';
import 'package:test_cursor/widgets/content/title.dart';
import 'package:test_cursor/widgets/content/cairo_time_indicator.dart';
import 'signature.dart';

class ContentBox extends StatelessWidget {
  const ContentBox({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1024;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen
            ? 16
            : isMediumScreen
            ? 32
            : 64,
        vertical: isSmallScreen ? 16 : 24,
      ),
      constraints: BoxConstraints(
        maxWidth: isSmallScreen ? double.infinity : 800,
        minHeight: isSmallScreen ? 320 : 350,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.85),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header with title and Cairo time
            Column(
              children: [
                const TitleText(),
                const SizedBox(height: 12),
                const CairoTimeIndicator(),
              ],
            ),

            // Counter (main content)
            const Expanded(child: Center(child: CounterText())),

            // Quote section
            const QuoteText(),

            // Signature
            const SignatureText(),
          ],
        ),
      ),
    );
  }
}
