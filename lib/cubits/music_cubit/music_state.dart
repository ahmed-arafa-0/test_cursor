// lib/cubits/music_cubit/music_state.dart
part of 'music_cubit.dart';

@immutable
sealed class MusicState {}

final class MusicHiddenState extends MusicState {}

final class MusicVisibleState extends MusicState {}

final class MusicPlayingState extends MusicState {
  final bool isPlaying;
  MusicPlayingState({required this.isPlaying});
}

final class MusicVolumeChangedState extends MusicState {
  final double volume;
  final bool isMuted;
  MusicVolumeChangedState({required this.volume, required this.isMuted});
}

final class MusicPositionChangedState extends MusicState {
  final double position;
  MusicPositionChangedState({required this.position});
}

final class MusicTrackChangedState extends MusicState {
  final int trackIndex;
  MusicTrackChangedState({required this.trackIndex});
}

final class MusicPlaylistUpdatedState extends MusicState {
  final List<Map<String, String>> playlist;
  MusicPlaylistUpdatedState({required this.playlist});
}
