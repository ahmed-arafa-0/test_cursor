import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:video_player/video_player.dart';
import '../../cubits/background_cubit/background_cubit.dart';
import '../../test.dart';
import 'asset_pic_bg.dart';
import 'network_pic_bg.dart';

class BackgroundBuilder extends StatelessWidget {
  const BackgroundBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundCubit, BackgroundCubitState>(
      builder: (context, state) {
        if (state is PictureBackgroundAssetState) {
          return AssetPictureBackground();
        } else if (state is PictureBackgroundNetworkState) {
          return NetworkPictureBackground();
        } else if (state is VideoBackgroundAssetState) {
          return TestWidget();
        } else if (state is VideoBackgroundNetworkState) {
          return TestWidget();
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
