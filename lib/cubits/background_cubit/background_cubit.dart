import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'background_state.dart';

class BackgroundCubit extends Cubit<BackgroundCubitState> {
  BackgroundCubit() : super(BackgroundLoadingState());
  bool isPicture = true;
  bool fromNetwork = false;
  void toggle() {
    isPicture = !isPicture;
    fromNetwork = !fromNetwork;
    emit(BackgroundLoadingState());
    if (isPicture) {
      if (fromNetwork) {
        emit(PictureBackgroundNetworkState());
      } else {
        emit(PictureBackgroundAssetState());
      }
    } else {
      if (fromNetwork) {
        emit(VideoBackgroundNetworkState());
      } else {
        emit(VideoBackgroundAssetState());
      }
    }
  }
}
