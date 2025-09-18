import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'music_state.dart';

class MusicCubit extends Cubit<MusicState> {
  MusicCubit() : super(MusicInitial());
}
