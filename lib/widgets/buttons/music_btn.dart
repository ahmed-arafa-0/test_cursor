import 'package:flutter/material.dart';

class MusicBtn extends StatelessWidget {
  const MusicBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.black45,
      // backgroundColor: Colors.white38,
      child: IconButton(
        onPressed: () {
          /*
        nusicPlayerVisable = !nusicPlayerVisable;
        setState(() {});
        */
        },
        icon: Icon(Icons.music_note, size: 20),
        color: Colors.white,
      ),
    );
  }
}
