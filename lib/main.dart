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
import 'widgets/background/complete_background_system.dart';
import 'widgets/music/complete_music_system.dart';

void main() {
  runApp(const VeoullaApp());
}

class VeoullaApp extends StatelessWidget {
  const VeoullaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Countdown cubit with FIXED Cairo timezone
        BlocProvider(
          create: (context) => CountdownCubit(
            targetDate: DateTime(2025, 9, 26), // Veuolla's birthday
          ),
        ),

        // Language management
        BlocProvider(create: (context) => LanguageCubit()),

        // Content management (Google Sheets integration)
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
          fontFamily: 'Pacifico',
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
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
          // COMPLETE BACKGROUND SYSTEM (with Google Sheets integration)
          const Positioned.fill(child: CompleteBackgroundSystem()),

          // Main content area with FIXED RTL support
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (isLandscape && constraints.maxWidth > 800) {
                    // Large landscape layout
                    return Row(
                      children: [
                        // Content takes main area
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(
                                top: 80,
                                bottom: 40,
                                left: 16,
                                right: 16,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 700,
                                ),
                                child:
                                    const CompleteCounterWidget(), // FIXED counter with RTL
                              ),
                            ),
                          ),
                        ),
                        // Music player sidebar for large screens
                        if (_showMusicPlayer)
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              child: const CompleteMusicPlayer(),
                            ),
                          ),
                      ],
                    );
                  } else {
                    // Standard layout for mobile and small screens
                    return Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: 80,
                          bottom: _showMusicPlayer ? 200 : 40,
                          left: 16,
                          right: 16,
                        ),
                        child:
                            const CompleteCounterWidget(), // FIXED counter with RTL
                      ),
                    );
                  }
                },
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
                    // Language switch button (ENHANCED)
                    const EnhancedLanguageSwitch(),

                    SizedBox(width: buttonSpacing),

                    // Background switch button (with CONTENT INTEGRATION)
                    const EnhancedBackgroundSwitchButton(),

                    SizedBox(width: buttonSpacing),

                    // Music player button (ENHANCED)
                    EnhancedMusicButton(
                      isVisible: _showMusicPlayer,
                      onPressed: _toggleMusicPlayer,
                    ),
                  ],
                );
              },
            ),
          ),

          // Enhanced Status Indicators
          Positioned(
            top: topPadding + 16,
            left: edgePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content status
                BlocBuilder<ContentCubit, ContentState>(
                  builder: (context, state) {
                    return _buildStatusChip(context: context, state: state);
                  },
                ),

                const SizedBox(height: 8),

                // Background status
                BlocBuilder<BackgroundCubit, BackgroundCubitState>(
                  builder: (context, state) {
                    return _buildBackgroundStatusChip(state);
                  },
                ),
              ],
            ),
          ),

          // Music player (for mobile/small screens)
          if (_showMusicPlayer && screenSize.width <= 800)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.95),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(top: false, child: const CompleteMusicPlayer()),
              ),
            ),

          // Debug time info (FIXED - shows correct Cairo time)
          if (screenSize.width > 600)
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
                          'Debug: ${state.formattedCountdown} | ${state.cairoTimeFormatted}',
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

  Widget _buildStatusChip({
    required BuildContext context,
    required ContentState state,
  }) {
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
        statusText = 'Live Data';
        statusColor = Colors.green;
        statusIcon = Icons.cloud_done;
      } else {
        statusText = 'Default';
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
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
  }

  Widget _buildBackgroundStatusChip(BackgroundCubitState state) {
    String statusText = '';
    Color statusColor = Colors.white60;
    IconData statusIcon = Icons.info_outline;

    if (state is BackgroundLoadingState) {
      statusText = 'BG Loading';
      statusColor = Colors.blue;
      statusIcon = Icons.image;
    } else if (state is PictureBackgroundNetworkState) {
      statusText = 'Net Image';
      statusColor = Colors.blue;
      statusIcon = Icons.photo;
    } else if (state is VideoBackgroundNetworkState) {
      statusText = 'Net Video';
      statusColor = Colors.red;
      statusIcon = Icons.videocam;
    } else if (state is PictureBackgroundAssetState) {
      statusText = 'Asset Image';
      statusColor = Colors.grey;
      statusIcon = Icons.photo_library;
    } else if (state is VideoBackgroundAssetState) {
      statusText = 'Asset Video';
      statusColor = Colors.grey;
      statusIcon = Icons.video_library;
    } else if (state is BackgroundErrorState) {
      statusText = 'BG Error';
      statusColor = Colors.red;
      statusIcon = Icons.error;
    }

    if (statusText.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
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
  }
}
