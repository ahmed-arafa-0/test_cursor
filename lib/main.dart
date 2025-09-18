import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cursor/cubits/background_cubit/background_cubit.dart';
// import 'package:test_cursor/test.dart';
// import 'views/loading_view.dart';
import 'views/countdown_view.dart';

void main() {
  runApp(VeoullaApp());
}

class VeoullaApp extends StatelessWidget {
  const VeoullaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BackgroundCubit(),
      child: MaterialApp(
        theme: ThemeData(
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.black54,
          ),
          scaffoldBackgroundColor: Colors.black,
        ),
        debugShowCheckedModeBanner: false,
        // home: LoadingView(),
        home: CountdownView(),
        // home: TestWidget(),
        title: 'Veoulla Birthday',
      ),
    );
  }
}
