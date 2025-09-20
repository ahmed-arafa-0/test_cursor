// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cursor/cubits/background_cubit/background_cubit.dart';
import 'package:test_cursor/cubits/language_cubit/language_cubit.dart';
import 'package:test_cursor/cubits/music_cubit/music_cubit.dart';
// Remove this import - ContentLoadCubit doesn't exist in your structure
// import 'package:test_cursor/cubits/content_cubit/content_load_cubit.dart';
import 'views/countdown_view.dart';

void main() {
  runApp(VeoullaApp());
}

class VeoullaApp extends StatelessWidget {
  const VeoullaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BackgroundCubit()),
        BlocProvider(create: (context) => LanguageCubit()),
        BlocProvider(create: (context) => MusicCubit()),
        // Remove ContentLoadCubit - it doesn't exist in your structure
      ],
      child: MaterialApp(
        theme: ThemeData(
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.black54,
          ),
          scaffoldBackgroundColor: Colors.black,
        ),
        debugShowCheckedModeBanner: false,
        home: const CountdownView(),
        title: 'Veoulla Birthday',
      ),
    );
  }
}
