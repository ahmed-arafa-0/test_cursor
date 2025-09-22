import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as html;
import 'dart:ui_web' as ui;
import 'dart:async';
import 'dart:developer';

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
        BlocProvider(
          create: (context) =>
              CountdownCubit(targetDate: DateTime(2025, 9, 26)),
        ),
        BlocProvider(create: (context) => LanguageCubit()),
        BlocProvider(create: (context) => ContentCubit()..initialize()),
        BlocProvider(create: (context) => BackgroundCubit()..initialize()),
      ],
      child: MaterialApp(
        title: 'Veuolla Birthday Countdown',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: 'Pacifico',
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
  int _backgroundMode =
      0; // 0=gradient, 1=asset_image, 2=network_image, 3=asset_video, 4=network_video

  // Video player
  html.HTMLVideoElement? _videoElement;
  String _currentVideoViewType = '';
  bool _videoInitialized = false;

  // Music player
  html.HTMLAudioElement? _audioElement;
  bool _isPlaying = false;
  double _currentTime = 0.0;
  double _duration = 0.0;
  double _volume = 0.7;
  int _currentTrackIndex = 0;
  Timer? _progressTimer;
  List<Map<String, String>> _playlist = [];

  @override
  void initState() {
    super.initState();
    _currentVideoViewType = 'video-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _toggleMusicPlayer() {
    setState(() {
      _showMusicPlayer = !_showMusicPlayer;
      if (_showMusicPlayer) {
        _initializeMusicPlayer();
      }
    });
  }

  void _toggleBackground() {
    setState(() {
      // Clean up video when switching
      if (_videoElement != null) {
        _videoElement!.pause();
        _videoElement = null;
        _videoInitialized = false;
      }

      _backgroundMode = (_backgroundMode + 1) % 5;

      // Initialize new video if needed
      if (_backgroundMode == 3 || _backgroundMode == 4) {
        _currentVideoViewType =
            'video-${DateTime.now().millisecondsSinceEpoch}';
        Future.delayed(const Duration(milliseconds: 100), () {
          _initializeVideo();
        });
      }
    });
  }

  void _initializeVideo() {
    try {
      String videoUrl = '';

      if (_backgroundMode == 3) {
        videoUrl = 'assets/videos/default.mp4';
      } else if (_backgroundMode == 4) {
        final contentCubit = context.read<ContentCubit>();
        if (contentCubit.currentContent != null) {
          final video = contentCubit.getCurrentVideo();
          if (!video.url.startsWith('assets/')) {
            videoUrl = video.url;
          } else {
            videoUrl = 'assets/videos/default.mp4';
          }
        } else {
          videoUrl = 'assets/videos/default.mp4';
        }
      }

      if (videoUrl.isEmpty) return;

      log('Initializing video: $videoUrl');

      _videoElement = html.HTMLVideoElement()
        ..src = videoUrl
        ..autoplay = true
        ..loop = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.position = 'absolute'
        ..style.top = '0'
        ..style.left = '0';

      _videoElement!.onCanPlay.listen((_) {
        log('Video can play');
        setState(() => _videoInitialized = true);
        _videoElement!.play();
      });

      _videoElement!.onError.listen((_) {
        log('Video error: ${_videoElement!.error?.message}');
      });

      // Register the video element
      ui.platformViewRegistry.registerViewFactory(
        _currentVideoViewType,
        (int viewId) => _videoElement!,
      );
    } catch (e) {
      log('Video initialization error: $e');
    }
  }

  void _initializeMusicPlayer() {
    final contentCubit = context.read<ContentCubit>();
    if (contentCubit.currentContent != null) {
      final musicList = contentCubit.getAllMusic();
      _playlist = musicList
          .map(
            (music) => {
              'title': music.songName,
              'artist': music.artistName,
              'url': music.url,
            },
          )
          .toList();

      if (_playlist.isNotEmpty) {
        _loadTrack(_currentTrackIndex);
      }
    }
  }

  void _loadTrack(int index) {
    if (index < 0 || index >= _playlist.length) return;

    try {
      _audioElement?.pause();
      _audioElement = html.HTMLAudioElement()
        ..src = _playlist[index]['url']!
        ..volume = _volume
        ..preload = 'metadata';

      _audioElement!.onCanPlay.listen((_) {
        setState(() {
          _duration = _audioElement!.duration.isFinite
              ? _audioElement!.duration
              : 0.0;
        });
      });

      _audioElement!.onTimeUpdate.listen((_) {
        if (_audioElement != null) {
          setState(() {
            _currentTime = _audioElement!.currentTime;
          });
        }
      });

      _audioElement!.onEnded.listen((_) {
        _nextTrack();
      });

      _audioElement!.onError.listen((_) {
        log('Audio error: ${_audioElement!.error}');
      });
    } catch (e) {
      log('Audio load error: $e');
    }
  }

  void _togglePlayPause() {
    if (_audioElement == null) return;

    try {
      if (_isPlaying) {
        _audioElement!.pause();
        _progressTimer?.cancel();
        setState(() => _isPlaying = false);
      } else {
        _audioElement!.play();
        _startProgressTimer();
        setState(() => _isPlaying = true);
      }
    } catch (e) {
      log('Play/pause error: $e');
    }
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_audioElement != null && _isPlaying) {
        setState(() {
          _currentTime = _audioElement!.currentTime;
        });
      }
    });
  }

  void _nextTrack() {
    if (_playlist.isEmpty) return;
    _currentTrackIndex = (_currentTrackIndex + 1) % _playlist.length;
    _loadTrack(_currentTrackIndex);
    if (_isPlaying) {
      Future.delayed(const Duration(milliseconds: 100), _togglePlayPause);
    }
  }

  void _previousTrack() {
    if (_playlist.isEmpty) return;
    _currentTrackIndex =
        (_currentTrackIndex - 1 + _playlist.length) % _playlist.length;
    _loadTrack(_currentTrackIndex);
    if (_isPlaying) {
      Future.delayed(const Duration(milliseconds: 100), _togglePlayPause);
    }
  }

  void _seekTo(double position) {
    if (_audioElement != null && _duration > 0) {
      _audioElement!.currentTime = position * _duration;
      setState(() => _currentTime = position * _duration);
    }
  }

  void _setVolume(double volume) {
    _volume = volume;
    _audioElement?.volume = volume;
    setState(() {});
  }

  Widget _buildBackground() {
    return BlocBuilder<ContentCubit, ContentState>(
      builder: (context, state) {
        switch (_backgroundMode) {
          case 1: // Asset Image
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/default.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            );

          case 2: // Network Image
            if (state is ContentLoaded) {
              final picture = context.read<ContentCubit>().getCurrentPicture();
              if (!picture.url.startsWith('assets/')) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(picture.url),
                      fit: BoxFit.cover,
                      onError: (error, stackTrace) =>
                          log('Network image error: $error'),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                );
              }
            }
            return _buildGradientBackground();

          case 3: // Asset Video
          case 4: // Network Video
            return Stack(
              children: [
                if (_videoInitialized && _videoElement != null)
                  Positioned.fill(
                    child: HtmlElementView(viewType: _currentVideoViewType),
                  )
                else
                  _buildGradientBackground(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            );

          default: // Gradient
            return _buildGradientBackground();
        }
      },
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.2),
            Colors.black,
            Colors.pink.withOpacity(0.2),
          ],
        ),
      ),
    );
  }

  String _getBackgroundModeText() {
    switch (_backgroundMode) {
      case 1:
        return 'Asset Image';
      case 2:
        return 'Net Image';
      case 3:
        return 'Asset Video';
      case 4:
        return 'Net Video';
      default:
        return 'Gradient';
    }
  }

  IconData _getBackgroundModeIcon() {
    switch (_backgroundMode) {
      case 1:
        return Icons.photo_library;
      case 2:
        return Icons.photo;
      case 3:
        return Icons.video_library;
      case 4:
        return Icons.videocam;
      default:
        return Icons.gradient;
    }
  }

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isCompact = screenSize.width < 600;

    final topPadding = mediaQuery.padding.top;
    final buttonSpacing = screenSize.width < 400 ? 8.0 : 12.0;
    final edgePadding = screenSize.width < 400 ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background with video support
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _buildBackground(),
            ),
          ),

          // Content
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: 80,
                    bottom: _showMusicPlayer
                        ? (isCompact ? 140 : 120)
                        : 40, // SMALLER
                    left: 16,
                    right: 16,
                  ),
                  child: BlocListener<ContentCubit, ContentState>(
                    listener: (context, state) {
                      if (state is ContentLoaded) {
                        setState(() {});
                        if (_showMusicPlayer && _playlist.isEmpty) {
                          _initializeMusicPlayer();
                        }
                      }
                    },
                    child: const CompleteCounterWidget(),
                  ),
                ),
              ),
            ),
          ),

          // Top buttons
          Positioned(
            top: topPadding + 16,
            right: edgePadding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const EnhancedLanguageSwitch(),
                SizedBox(width: buttonSpacing),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _backgroundMode == 0
                          ? Colors.white.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    onPressed: _toggleBackground,
                    icon: Icon(
                      _getBackgroundModeIcon(),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: buttonSpacing),
                EnhancedMusicButton(
                  isVisible: _showMusicPlayer,
                  onPressed: _toggleMusicPlayer,
                ),
              ],
            ),
          ),

          // Status indicators
          Positioned(
            top: topPadding + 16,
            left: edgePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<ContentCubit, ContentState>(
                  builder: (context, state) {
                    String status = 'Loading...';
                    Color color = Colors.yellow;
                    IconData icon = Icons.sync;

                    if (state is ContentLoaded) {
                      final contentCubit = context.read<ContentCubit>();
                      if (contentCubit.isUsingNetworkContent) {
                        status = 'Live Data';
                        color = Colors.green;
                        icon = Icons.cloud_done;
                      } else {
                        status = 'Default';
                        color = Colors.orange;
                        icon = Icons.cloud_off;
                      }
                    } else if (state is ContentError) {
                      status = 'Offline';
                      color = Colors.red;
                      icon = Icons.error_outline;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: color, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _backgroundMode == 0
                          ? Colors.grey.withOpacity(0.5)
                          : Colors.blue.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getBackgroundModeIcon(),
                        color: _backgroundMode == 0 ? Colors.grey : Colors.blue,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getBackgroundModeText(),
                        style: TextStyle(
                          color: _backgroundMode == 0
                              ? Colors.grey
                              : Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // COMPACT Music Player with ALL working features
          if (_showMusicPlayer)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSlide(
                offset: _showMusicPlayer ? Offset.zero : const Offset(0, 1),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Container(
                  margin: const EdgeInsets.all(8), // VERY SMALL margins
                  padding: const EdgeInsets.all(10), // VERY SMALL padding
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12), // SMALLER radius
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // COMPACT Header
                      Row(
                        children: [
                          const Text(
                            '🎵',
                            style: TextStyle(fontSize: 14),
                          ), // SMALLER emoji
                          const SizedBox(width: 6),
                          Expanded(
                            child: _playlist.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _playlist[_currentTrackIndex]['title']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ), // SMALLER
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _playlist[_currentTrackIndex]['artist']!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ), // SMALLER
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'No tracks',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                          ),
                          IconButton(
                            onPressed: _toggleMusicPlayer,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white70,
                              size: 18,
                            ), // SMALLER
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ), // SMALLER
                          ),
                        ],
                      ),

                      // WORKING Progress slider
                      Row(
                        children: [
                          Text(
                            _formatTime(_currentTime),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                          ), // SMALLER
                          Expanded(
                            child: Slider(
                              value: _duration > 0
                                  ? (_currentTime / _duration).clamp(0.0, 1.0)
                                  : 0.0,
                              onChanged: _seekTo,
                              activeColor: Colors.white,
                              inactiveColor: Colors.white30,
                            ),
                          ),
                          Text(
                            _formatTime(_duration),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                          ), // SMALLER
                        ],
                      ),

                      // COMPACT Controls with REAL functionality
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: _previousTrack, // WORKING previous
                            icon: const Icon(
                              Icons.skip_previous,
                              color: Colors.white70,
                              size: 20,
                            ), // SMALLER
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ), // SMALLER
                          ),
                          Container(
                            width: 36, // SMALLER
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _togglePlayPause, // WORKING play/pause
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.black,
                                size: 18,
                              ), // SMALLER
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          IconButton(
                            onPressed: _nextTrack, // WORKING next
                            icon: const Icon(
                              Icons.skip_next,
                              color: Colors.white70,
                              size: 20,
                            ), // SMALLER
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ), // SMALLER
                          ),
                        ],
                      ),

                      // WORKING Volume control
                      Row(
                        children: [
                          Icon(
                            _volume == 0
                                ? Icons.volume_off
                                : (_volume < 0.5
                                      ? Icons.volume_down
                                      : Icons.volume_up),
                            color: Colors.white70,
                            size: 14, // SMALLER
                          ),
                          Expanded(
                            child: Slider(
                              value: _volume,
                              onChanged: _setVolume, // WORKING volume control
                              activeColor: Colors.white70,
                              inactiveColor: Colors.white30,
                            ),
                          ),
                          Text(
                            '${(_volume * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                          ), // SMALLER
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoElement?.pause();
    _audioElement?.pause();
    _progressTimer?.cancel();
    super.dispose();
  }
}
