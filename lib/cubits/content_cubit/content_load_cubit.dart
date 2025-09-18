import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'content_load_state.dart';

class ContentLoadCubit extends Cubit<ContentLoadState> {
  ContentLoadCubit() : super(ContentLoadInitial());
}
