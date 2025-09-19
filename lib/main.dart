import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import all the cubits
import 'cubits/countdown_cubit/countdown_cubit.dart';
import 'cubits/language_cubit/language_cubit.dart';
import 'cubits/content_cubit/content_cubit.dart';
import 'cubits/background_cubit/background_cubit.dart';

// Import widgets
import 'widgets/content/complete_counter_widget.dart';
import 'widgets/buttons/enhanced_buttons.dart';

void main() {
  runApp(const VeoullaApp());
}

class VeoullaApp extends StatelessWidget {
  const VeoullaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Countdown cubit with Cairo timezone
        BlocProvider(
          create: (context) => CountdownCubit(
            targetDate: DateTime(2025, 9, 26), // Veuolla's birthday
          ),
        ),

        // Language management
        BlocProvider(create: (context) => LanguageCubit()),

        // Content management (quotes, music, etc.)
        BlocProvider(create: (context) => ContentCubit()..initialize()),

        // Background management
        BlocProvider(create: (context) => BackgroundCubit()..initialize()),
      ],
      child: MaterialApp(
        title: 'Veuolla Birthday Countdown',
        debugShowCheckedModeBanner: false,

        // Theme optimized for birthday countdown
        theme: ThemeData(
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: Colors.black,

          // Font theme
          fontFamily: 'Pacifico',

          // Bottom sheet theme
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),

          // App bar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),

        home: const CountdownHomePage(),
      ),
    );
  }
}

class CountdownHomePage extends StatefulWidget {
  const CountdownHomePage({super.key});

  @override
  State<CountdownHomePage> createState() => _CountdownHomePageState();
}

class _CountdownHomePageState extends State<CountdownHomePage> {
  bool _showMusicPlayer = false;

  void _toggleMusicPlayer() {
    setState(() {
      _showMusicPlayer = !_showMusicPlayer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Responsive button positioning
    final topPadding = mediaQuery.padding.top;
    final buttonSpacing = screenSize.width < 400 ? 8.0 : 12.0;
    final edgePadding = screenSize.width < 400 ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [
          // Background gradient (placeholder for now)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withOpacity(0.1),
                  Colors.black,
                  Colors.pink.withOpacity(0.1),
                ],
              ),
            ),
          ),

          // Main content area
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: 80, // Space for buttons
                    bottom: _showMusicPlayer ? 200 : 40,
                    left: 16,
                    right: 16,
                  ),
                  child: const CompleteCounterWidget(),
                ),
              ),
            ),
          ),

          // Top control buttons
          Positioned(
            top: topPadding + 16,
            right: edgePadding,
            child: BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, state) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Language switch button
                    const EnhancedLanguageSwitch(),

                    SizedBox(width: buttonSpacing),

                    // Background switch button (placeholder for now)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.image,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),

                    SizedBox(width: buttonSpacing),

                    // Music player button
                    EnhancedMusicButton(
                      isVisible: _showMusicPlayer,
                      onPressed: _toggleMusicPlayer,
                    ),
                  ],
                );
              },
            ),
          ),

          // Content status indicator (shows data loading status)
          Positioned(
            top: topPadding + 16,
            left: edgePadding,
            child: BlocBuilder<ContentCubit, ContentState>(
              builder: (context, state) {
                String statusText = '';
                Color statusColor = Colors.white60;
                IconData statusIcon = Icons.info_outline;

                if (state is ContentInitializing || state is ContentLoading) {
                  statusText = 'Loading...';
                  statusColor = Colors.yellow;
                  statusIcon = Icons.sync;
                } else if (state is ContentLoaded) {
                  final contentCubit = context.read<ContentCubit>();
                  if (contentCubit.isUsingNetworkContent) {
                    statusText = 'Live';
                    statusColor = Colors.green;
                    statusIcon = Icons.cloud_done;
                  } else {
                    statusText = 'Offline';
                    statusColor = Colors.orange;
                    statusIcon = Icons.cloud_off;
                  }
                } else if (state is ContentError) {
                  statusText = 'Offline';
                  statusColor = Colors.red;
                  statusIcon = Icons.error_outline;
                }

                if (statusText.isEmpty) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Music player (when visible)
          if (_showMusicPlayer)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Music player placeholder
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                '🎵 Music Player',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Will be integrated with Google Sheets data',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Debug info (bottom center) - Remove in production
          if (MediaQuery.of(context).size.width > 600)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: BlocBuilder<CountdownCubit, CountdownState>(
                  builder: (context, state) {
                    if (state is CountdownTicking) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Debug: ${state.formattedCountdown} | Cairo: ${state.cairoTime.hour}:${state.cairoTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Error boundary widget for debugging
class AppErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const AppErrorWidget({super.key, required this.error, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'App Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                if (stackTrace != null) ...[
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        stackTrace.toString(),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
