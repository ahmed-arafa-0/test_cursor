// lib/cubits/music_cubit/music_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'music_state.dart';

class MusicCubit extends Cubit<MusicState> {
  MusicCubit() : super(MusicHiddenState());

  bool _isVisible = false;
  bool _isPlaying = false;
  bool _isMuted = false;
  double _volume = 0.8;
  double _position = 0.0;
  int _currentTrackIndex = 0;

  List<Map<String, String>> _playlist = [
    {
      'title': 'Birthday Melody 🎵',
      'artist': 'Happy Orchestra 🎻',
      'duration': '3:45',
      'url': 'assets/songs/default.mp3',
    },
  ];

  // Getters
  bool get isVisible => _isVisible;
  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  double get volume => _volume;
  double get position => _position;
  int get currentTrackIndex => _currentTrackIndex;
  List<Map<String, String>> get playlist => _playlist;
  Map<String, String> get currentTrack =>
      _playlist.isNotEmpty ? _playlist[_currentTrackIndex] : {};

  void toggleVisibility() {
    _isVisible = !_isVisible;
    if (_isVisible) {
      emit(MusicVisibleState());
    } else {
      emit(MusicHiddenState());
    }
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    emit(MusicPlayingState(isPlaying: _isPlaying));
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _volume = 0.0;
    } else {
      _volume = 0.8;
    }
    emit(MusicVolumeChangedState(volume: _volume, isMuted: _isMuted));
  }

  void setVolume(double volume) {
    _volume = volume;
    _isMuted = volume == 0.0;
    emit(MusicVolumeChangedState(volume: _volume, isMuted: _isMuted));
  }

  void setPosition(double position) {
    _position = position;
    emit(MusicPositionChangedState(position: _position));
  }

  void nextTrack() {
    _currentTrackIndex = (_currentTrackIndex + 1) % _playlist.length;
    emit(MusicTrackChangedState(trackIndex: _currentTrackIndex));
  }

  void previousTrack() {
    _currentTrackIndex = (_currentTrackIndex - 1) % _playlist.length;
    if (_currentTrackIndex < 0) _currentTrackIndex = _playlist.length - 1;
    emit(MusicTrackChangedState(trackIndex: _currentTrackIndex));
  }

  void updatePlaylist(List<Map<String, String>> newPlaylist) {
    if (newPlaylist.isNotEmpty) {
      _playlist = newPlaylist;
      _currentTrackIndex = 0;
      emit(MusicPlaylistUpdatedState(playlist: _playlist));
    }
  }

  void seekForward() {
    // Skip 5 seconds forward
    _position = (_position + 5.0).clamp(0.0, 100.0);
    emit(MusicPositionChangedState(position: _position));
  }

  void seekBackward() {
    // Skip 5 seconds backward
    _position = (_position - 5.0).clamp(0.0, 100.0);
    emit(MusicPositionChangedState(position: _position));
  }
}
