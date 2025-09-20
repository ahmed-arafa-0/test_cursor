// lib/widgets/buttons/music_btn.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/music_cubit/music_cubit.dart';

class MusicBtn extends StatelessWidget {
  const MusicBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicCubit, MusicState>(
      builder: (context, state) {
        final musicCubit = context.read<MusicCubit>();
        final isVisible = musicCubit.isVisible;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isVisible ? Colors.white24 : Colors.black45,
            shape: BoxShape.circle,
            border: isVisible
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: IconButton(
            onPressed: () {
              context.read<MusicCubit>().toggleVisibility();
            },
            icon: Icon(
              Icons.music_note,
              size: 20,
              color: isVisible ? Colors.yellow : Colors.white,
            ),
            tooltip: isVisible ? 'Hide Music Player' : 'Show Music Player',
          ),
        );
      },
    );
  }
}
