import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as html;
import 'dart:async';
import 'dart:developer';
import '../../cubits/content_cubit/content_cubit.dart';
import '../../models/data_models.dart';

// Music Player Cubit
class MusicPlayerCubit extends Cubit<MusicPlayerState> {
  MusicPlayerCubit() : super(MusicPlayerInitial());

  bool _isPlaying = false;
  bool _isMuted = false;
  double _volume = 0.7;
  double _progress = 0.0;
  int _currentTrackIndex = 0;
  List<Music> _playlist = [];
  Timer? _progressTimer;
  html.HTMLAudioElement? _audioElement;

  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  double get volume => _volume;
  double get progress => _progress;
  int get currentTrackIndex => _currentTrackIndex;
  List<Music> get playlist => _playlist;

  void initialize(List<Music> playlist) {
    _playlist = playlist;
    if (_playlist.isNotEmpty) {
      _initializeAudio();
      emit(
        MusicPlayerReady(
          currentTrack: _playlist[_currentTrackIndex],
          isPlaying: _isPlaying,
          volume: _volume,
          progress: _progress,
        ),
      );
    } else {
      emit(MusicPlayerError('No music available'));
    }
  }

  void _initializeAudio() {
    try {
      _audioElement?.pause();
      _audioElement = html.HTMLAudioElement();

      if (_playlist.isNotEmpty) {
        final currentTrack = _playlist[_currentTrackIndex];
        _audioElement!.src = currentTrack.url;
        _audioElement!.volume = _isMuted ? 0 : _volume;
        _audioElement!.preload = 'metadata';

        // Add event listeners
        _audioElement!.onCanPlay.listen((_) {
          log('Audio ready to play: ${currentTrack.songName}');
        });

        _audioElement!.onError.listen((_) {
          log('Audio error: ${_audioElement!.error}');
          emit(MusicPlayerError('Failed to load audio'));
        });

        _audioElement!.onEnded.listen((_) {
          nextTrack();
        });

        _audioElement!.onTimeUpdate.listen((_) {
          if (_audioElement!.duration > 0) {
            _progress = _audioElement!.currentTime / _audioElement!.duration;
            _emitCurrentState();
          }
        });
      }
    } catch (e) {
      log('Audio initialization error: $e');
      emit(MusicPlayerError('Failed to initialize audio: $e'));
    }
  }

  void togglePlayPause() {
    try {
      if (_audioElement == null) return;

      if (_isPlaying) {
        _audioElement!.pause();
        _isPlaying = false;
        _stopProgressTimer();
      } else {
        // Handle browser autoplay restrictions
        try {
          try {
            _audioElement!.play();
          } finally {
            _isPlaying = true;
            _startProgressTimer();
          }
        } on Exception catch (e) {
          log('Play error (autoplay restriction): $e');
          emit(MusicPlayerError('Cannot play - user interaction required'));
        }
        // _audioElement!.play().then((_) {
        //   _isPlaying = true;
        //   _startProgressTimer();
        // }).catchError((error) {
        //   log('Play error (autoplay restriction): $error');
        //   emit(MusicPlayerError('Cannot play - user interaction required'));
        // });
      }

      _emitCurrentState();
    } catch (e) {
      log('Toggle play/pause error: $e');
      emit(MusicPlayerError('Playback error: $e'));
    }
  }

  void nextTrack() {
    if (_playlist.isEmpty) return;

    _currentTrackIndex = (_currentTrackIndex + 1) % _playlist.length;
    _progress = 0.0;
    _initializeAudio();

    if (_isPlaying) {
      // Small delay to ensure audio is loaded
      Future.delayed(const Duration(milliseconds: 100), () {
        togglePlayPause();
      });
    }

    _emitCurrentState();
  }

  void previousTrack() {
    if (_playlist.isEmpty) return;

    _currentTrackIndex =
        (_currentTrackIndex - 1 + _playlist.length) % _playlist.length;
    _progress = 0.0;
    _initializeAudio();

    if (_isPlaying) {
      Future.delayed(const Duration(milliseconds: 100), () {
        togglePlayPause();
      });
    }

    _emitCurrentState();
  }

  void setVolume(double newVolume) {
    _volume = newVolume.clamp(0.0, 1.0);
    _isMuted = _volume == 0.0;

    if (_audioElement != null) {
      _audioElement!.volume = _volume;
    }

    _emitCurrentState();
  }

  void toggleMute() {
    _isMuted = !_isMuted;

    if (_audioElement != null) {
      _audioElement!.volume = _isMuted ? 0 : _volume;
    }

    _emitCurrentState();
  }

  void seekTo(double position) {
    if (_audioElement != null && _audioElement!.duration > 0) {
      _progress = position.clamp(0.0, 1.0);
      _audioElement!.currentTime = _progress * _audioElement!.duration;
      _emitCurrentState();
    }
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_audioElement != null && _audioElement!.duration > 0) {
        _progress = _audioElement!.currentTime / _audioElement!.duration;
        _emitCurrentState();
      }
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  void _emitCurrentState() {
    if (_playlist.isNotEmpty && state is! MusicPlayerError) {
      emit(
        MusicPlayerReady(
          currentTrack: _playlist[_currentTrackIndex],
          isPlaying: _isPlaying,
          volume: _isMuted ? 0 : _volume,
          progress: _progress,
        ),
      );
    }
  }

  String getCurrentTime() {
    if (_audioElement == null) return '0:00';
    final seconds = _audioElement!.currentTime.round();
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String getTotalTime() {
    if (_audioElement == null || _audioElement!.duration.isNaN) return '0:00';
    final seconds = _audioElement!.duration.round();
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> close() {
    _stopProgressTimer();
    _audioElement?.pause();
    _audioElement = null;
    return super.close();
  }
}

// Music Player States
abstract class MusicPlayerState {}

class MusicPlayerInitial extends MusicPlayerState {}

class MusicPlayerReady extends MusicPlayerState {
  final Music currentTrack;
  final bool isPlaying;
  final double volume;
  final double progress;

  MusicPlayerReady({
    required this.currentTrack,
    required this.isPlaying,
    required this.volume,
    required this.progress,
  });
}

class MusicPlayerError extends MusicPlayerState {
  final String message;
  MusicPlayerError(this.message);
}

// Complete Music Player Widget
class CompleteMusicPlayer extends StatefulWidget {
  const CompleteMusicPlayer({super.key});

  @override
  State<CompleteMusicPlayer> createState() => _CompleteMusicPlayerState();
}

class _CompleteMusicPlayerState extends State<CompleteMusicPlayer>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _playButtonController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _playButtonAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    _playButtonAnimation = CurvedAnimation(
      parent: _playButtonController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _playButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isCompact = screenSize.width < 400;

    return BlocProvider(
      create: (context) => MusicPlayerCubit(),
      child: BlocBuilder<ContentCubit, ContentState>(
        builder: (context, contentState) {
          // Initialize music player with current content
          if (contentState is ContentLoaded) {
            final musicList = context.read<ContentCubit>().getAllMusic();
            context.read<MusicPlayerCubit>().initialize(musicList);
          }

          return SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.all(isCompact ? 12.0 : 16.0),
              padding: EdgeInsets.all(isCompact ? 16.0 : 20.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: BlocBuilder<MusicPlayerCubit, MusicPlayerState>(
                builder: (context, musicState) {
                  if (musicState is MusicPlayerError) {
                    return _buildErrorState(musicState.message, isCompact);
                  } else if (musicState is MusicPlayerReady) {
                    return _buildMusicPlayer(musicState, isCompact);
                  } else {
                    return _buildLoadingState(isCompact);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMusicPlayer(MusicPlayerReady state, bool isCompact) {
    final musicCubit = context.read<MusicPlayerCubit>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Track info
        _buildTrackInfo(state.currentTrack, isCompact),

        SizedBox(height: isCompact ? 16 : 20),

        // Progress bar
        _buildProgressBar(state, musicCubit, isCompact),

        SizedBox(height: isCompact ? 16 : 20),

        // Control buttons
        _buildControlButtons(state, musicCubit, isCompact),

        SizedBox(height: isCompact ? 16 : 20),

        // Volume control
        _buildVolumeControl(state, musicCubit, isCompact),

        if (!isCompact) ...[
          const SizedBox(height: 12),
          _buildPlaylistInfo(musicCubit),
        ],
      ],
    );
  }

  Widget _buildTrackInfo(Music track, bool isCompact) {
    return Column(
      children: [
        Text(
          track.songName,
          style: TextStyle(
            color: Colors.white,
            fontSize: isCompact ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          track.artistName,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isCompact ? 13 : 14,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    MusicPlayerReady state,
    MusicPlayerCubit musicCubit,
    bool isCompact,
  ) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white30,
            thumbColor: Colors.white,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: isCompact ? 8 : 10,
            ),
            overlayColor: Colors.white.withOpacity(0.2),
            trackHeight: 3,
          ),
          child: Slider(
            value: state.progress,
            onChanged: (value) {
              musicCubit.seekTo(value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                musicCubit.getCurrentTime(),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isCompact ? 11 : 12,
                ),
              ),
              Text(
                musicCubit.getTotalTime(),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isCompact ? 11 : 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(
    MusicPlayerReady state,
    MusicPlayerCubit musicCubit,
    bool isCompact,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous
        _ControlButton(
          icon: Icons.skip_previous,
          onPressed: musicCubit.previousTrack,
          size: isCompact ? 30 : 36,
        ),

        // Rewind 10 seconds
        _ControlButton(
          icon: Icons.replay_10,
          onPressed: () {
            final newProgress = (state.progress - 0.05).clamp(0.0, 1.0);
            musicCubit.seekTo(newProgress);
          },
          size: isCompact ? 24 : 28,
        ),

        // Play/Pause
        AnimatedBuilder(
          animation: _playButtonAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_playButtonAnimation.value * 0.1),
              child: Container(
                width: isCompact ? 56 : 64,
                height: isCompact ? 56 : 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      state.isPlaying ? Icons.pause : Icons.play_arrow,
                      key: ValueKey(state.isPlaying),
                      color: Colors.black,
                      size: isCompact ? 28 : 32,
                    ),
                  ),
                  onPressed: () {
                    _playButtonController.forward().then(
                      (_) => _playButtonController.reverse(),
                    );
                    musicCubit.togglePlayPause();
                  },
                ),
              ),
            );
          },
        ),

        // Forward 10 seconds
        _ControlButton(
          icon: Icons.forward_10,
          onPressed: () {
            final newProgress = (state.progress + 0.05).clamp(0.0, 1.0);
            musicCubit.seekTo(newProgress);
          },
          size: isCompact ? 24 : 28,
        ),

        // Next
        _ControlButton(
          icon: Icons.skip_next,
          onPressed: musicCubit.nextTrack,
          size: isCompact ? 30 : 36,
        ),
      ],
    );
  }

  Widget _buildVolumeControl(
    MusicPlayerReady state,
    MusicPlayerCubit musicCubit,
    bool isCompact,
  ) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            state.volume == 0
                ? Icons.volume_off
                : state.volume < 0.5
                ? Icons.volume_down
                : Icons.volume_up,
            color: Colors.white70,
            size: isCompact ? 20 : 24,
          ),
          onPressed: musicCubit.toggleMute,
        ),

        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.white70,
              inactiveTrackColor: Colors.white30,
              thumbColor: Colors.white70,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: isCompact ? 6 : 8,
              ),
              overlayColor: Colors.white.withOpacity(0.1),
              trackHeight: 2,
            ),
            child: Slider(value: state.volume, onChanged: musicCubit.setVolume),
          ),
        ),

        Text(
          '${(state.volume * 100).round()}%',
          style: TextStyle(
            color: Colors.white70,
            fontSize: isCompact ? 11 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistInfo(MusicPlayerCubit musicCubit) {
    final playlist = musicCubit.playlist;
    final currentIndex = musicCubit.currentTrackIndex;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.playlist_play, color: Colors.white60, size: 16),
          const SizedBox(width: 6),
          Text(
            'Track ${currentIndex + 1} of ${playlist.length}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: isCompact ? 32 : 40,
          ),
          const SizedBox(height: 12),
          Text(
            'Music Player Error',
            style: TextStyle(
              color: Colors.white,
              fontSize: isCompact ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isCompact ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Retry initialization
              final contentCubit = context.read<ContentCubit>();
              if (contentCubit.currentContent != null) {
                final musicList = contentCubit.getAllMusic();
                context.read<MusicPlayerCubit>().initialize(musicList);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          const SizedBox(height: 16),
          Text(
            'Loading music...',
            style: TextStyle(
              color: Colors.white,
              fontSize: isCompact ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  void showPlayer() {
    _slideController.forward();
  }

  void hidePlayer() {
    _slideController.reverse();
  }
}

// Control Button Widget
class _ControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.size,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.forward();
    widget.onPressed();
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: IconButton(
            icon: Icon(widget.icon, color: Colors.white70, size: widget.size),
            onPressed: _handleTap,
          ),
        );
      },
    );
  }
}
