// lib/widgets/content/cairo_time_indicator.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CairoTimeIndicator extends StatefulWidget {
  const CairoTimeIndicator({super.key});

  @override
  State<CairoTimeIndicator> createState() => _CairoTimeIndicatorState();
}

class _CairoTimeIndicatorState extends State<CairoTimeIndicator> {
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    // Get current time in Cairo (UTC+2)
    final cairoTime = DateTime.now().toUtc().add(const Duration(hours: 2));
    final formatter = DateFormat('HH:mm:ss');

    if (mounted) {
      setState(() {
        _currentTime = formatter.format(cairoTime);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(
            'Cairo $_currentTime',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
