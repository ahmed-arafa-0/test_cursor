// lib/widgets/background/network_pic_bg.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/background_cubit/background_cubit.dart';

class NetworkPictureBackground extends StatelessWidget {
  const NetworkPictureBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundCubit, BackgroundCubitState>(
      builder: (context, state) {
        final backgroundCubit = context.read<BackgroundCubit>();
        final imageUrl = backgroundCubit.currentImageUrl;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: Container(
            key: ValueKey(imageUrl),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageUrl.startsWith('http')
                    ? NetworkImage(imageUrl)
                    : AssetImage(imageUrl) as ImageProvider,
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Handle image loading error
                  debugPrint('Background image failed to load: $exception');
                },
              ),
            ),
            child: Container(
              // Add subtle overlay for better content readability
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
