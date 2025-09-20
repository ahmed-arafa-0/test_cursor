// lib/widgets/music/music_player.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/music_cubit/music_cubit.dart';
import '../../services/google_sheet_service.dart';
import 'package:intl/intl.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _hasNetworkData = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    _loadTodaysMusic();
  }

  Future<void> _loadTodaysMusic() async {
    try {
      // Get today's date in Cairo timezone
      final cairoTime = DateTime.now().toUtc().add(const Duration(hours: 2));
      final today = DateFormat('yyyy-MM-dd').format(cairoTime);

      // Fetch music from Google Sheets
      final music = await fetchSheetByGid('191122548'); // GID for music sheet

      // Find today's music
      final todaysMusic = music
          .where((track) => track['Date'] == today)
          .toList();

      if (mounted) {
        final musicCubit = context.read<MusicCubit>();

        if (todaysMusic.isNotEmpty) {
          // Convert to playlist format
          final playlist = todaysMusic.map((track) {
            return {
              'title':
                  track['Song Name'] ??
                  track['Name']?.replaceAll('.mp3', '') ??
                  'Unknown Track',
              'artist': track['Artist Name'] ?? 'Unknown Artist',
              'duration': '3:45', // Could be calculated from actual file
              'url': track['URL'] ?? 'assets/songs/default.mp3',
            };
          }).toList();

          musicCubit.updatePlaylist(playlist);
          _hasNetworkData = true;
        } else {
          _hasNetworkData = false;
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasNetworkData = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  String _formatDuration(double position) {
    final minutes = (position / 60).floor();
    final seconds = (position % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MusicCubit, MusicState>(
      listener: (context, state) {
        if (state is MusicVisibleState) {
          _slideController.forward();
        } else if (state is MusicHiddenState) {
          _slideController.reverse();
        }
      },
      builder: (context, state) {
        final musicCubit = context.read<MusicCubit>();

        if (!musicCubit.isVisible) {
          return const SizedBox.shrink();
        }

        final currentTrack = musicCubit.currentTrack;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 600;

        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar with time indicators
                Row(
                  children: [
                    Text(
                      _formatDuration(musicCubit.position),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: musicCubit.position / 100,
                        onChanged: (value) {
                          context.read<MusicCubit>().setPosition(value * 100);
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.white30,
                        thumbColor: Colors.yellow,
                      ),
                    ),
                    const Text(
                      "3:45", // Default duration
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Track info with data source indicator
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currentTrack['title'] ?? 'Birthday Melody 🎵',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Data source indicator
                              Icon(
                                _hasNetworkData
                                    ? Icons.cloud_done
                                    : Icons.cloud_off,
                                size: 14,
                                color: _hasNetworkData
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _hasNetworkData ? 'Live' : 'Offline',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _hasNetworkData
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            currentTrack['artist'] ?? 'Happy Orchestra 🎻',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous track
                    IconButton(
                      onPressed: () =>
                          context.read<MusicCubit>().previousTrack(),
                      icon: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                      ),
                      iconSize: isSmallScreen ? 24 : 28,
                    ),

                    // Rewind 5 seconds
                    IconButton(
                      onPressed: () =>
                          context.read<MusicCubit>().seekBackward(),
                      icon: const Icon(Icons.replay_5, color: Colors.white70),
                      iconSize: isSmallScreen ? 20 : 24,
                    ),

                    // Play/Pause
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () =>
                            context.read<MusicCubit>().togglePlayPause(),
                        icon: Icon(
                          musicCubit.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                        ),
                        iconSize: isSmallScreen ? 28 : 32,
                      ),
                    ),

                    // Forward 5 seconds
                    IconButton(
                      onPressed: () => context.read<MusicCubit>().seekForward(),
                      icon: const Icon(Icons.forward_5, color: Colors.white70),
                      iconSize: isSmallScreen ? 20 : 24,
                    ),

                    // Next track
                    IconButton(
                      onPressed: () => context.read<MusicCubit>().nextTrack(),
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      iconSize: isSmallScreen ? 24 : 28,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Volume control
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => context.read<MusicCubit>().toggleMute(),
                      icon: Icon(
                        musicCubit.isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white70,
                      ),
                      iconSize: isSmallScreen ? 20 : 24,
                    ),

                    Expanded(
                      child: Slider(
                        value: musicCubit.volume,
                        onChanged: (value) {
                          context.read<MusicCubit>().setVolume(value);
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.white30,
                        thumbColor: Colors.yellow,
                        min: 0.0,
                        max: 1.0,
                      ),
                    ),

                    Text(
                      '${(musicCubit.volume * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
