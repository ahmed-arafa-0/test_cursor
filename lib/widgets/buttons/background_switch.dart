import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cursor/cubits/background_cubit/background_cubit.dart';

class BackgroundSwitch extends StatefulWidget {
  const BackgroundSwitch({super.key});

  @override
  State<BackgroundSwitch> createState() => _BackgroundSwitchState();
}

class _BackgroundSwitchState extends State<BackgroundSwitch> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.black45,
      child: IconButton(
        onPressed: () {
          BlocProvider.of<BackgroundCubit>(context).toggle();
          setState(() {});
        },
        icon: !BlocProvider.of<BackgroundCubit>(context).isPicture
            ? Icon(Icons.photo_size_select_actual_rounded, size: 20)
            : Icon(Icons.video_camera_back, size: 20),
        color: Colors.white,
      ),
    );
  }
}
