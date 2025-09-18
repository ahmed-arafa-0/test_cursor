import 'package:flutter/material.dart';
import 'package:test_cursor/widgets/content/content_box.dart';
import '../widgets/background/background_builder.dart';
import '../widgets/buttons/music_btn.dart';
import '../widgets/buttons/language_switch.dart';
import '../widgets/buttons/background_switch.dart';
import '../widgets/music/music_player.dart';

class CountdownView extends StatefulWidget {
  const CountdownView({super.key});

  @override
  State<CountdownView> createState() => _CountdownViewState();
}

class _CountdownViewState extends State<CountdownView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          LanguageSwitch(),
          SizedBox(width: 5.0),
          BackgroundSwitch(),
          SizedBox(width: 5.0),
          MusicBtn(),
          SizedBox(width: 5.0),
        ],
      ),
      body: Stack(
        children: [
          BackgroundBuilder(),
          Center(child: ContentBox()),
        ],
      ),
      bottomSheet: MusicPlayer(),
    );
  }
}
