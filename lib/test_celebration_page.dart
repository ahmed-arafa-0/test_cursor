// TEST FILE: lib/test_celebration_page.dart
// Add this to test the celebration animations immediately

import 'package:flutter/material.dart';
import 'widgets/celebration/birthday_celebration.dart';

class TestCelebrationPage extends StatefulWidget {
  const TestCelebrationPage({super.key});

  @override
  State<TestCelebrationPage> createState() => _TestCelebrationPageState();
}

class _TestCelebrationPageState extends State<TestCelebrationPage> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.black,
                  Colors.pink.withOpacity(0.3),
                ],
              ),
            ),
          ),

          // Celebration animations
          BirthdyCelebration(isActive: _isActive),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🎉 Test Celebration Page 🎉',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        _isActive
                            ? '🎊 Celebration Active! 🎊'
                            : 'Press button to start celebration',
                        style: TextStyle(
                          color: _isActive ? Colors.yellow : Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isActive = !_isActive;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isActive
                              ? Colors.red
                              : Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          _isActive ? 'Stop Celebration' : 'Start Celebration',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Back button
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Main App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
