import 'package:flutter/material.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 8.0,
        left: 8.0,
        top: 8.0,
        bottom: 16,
      ),
      child: SizedBox(
        // width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text("00:01", style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Slider(
                    value: 0.5,
                    onChanged: (value) {},
                    thumbColor: Colors.white,
                    activeColor: Colors.white70,
                    inactiveColor: Colors.white10,
                  ),
                ),
                Text("00:01", style: TextStyle(color: Colors.white)),
              ],
            ),
            Text(
              "Song Name - Artist Name",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.navigate_before, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.replay_5),
                  color: Colors.white,
                ),
                // IconButton(onPressed: () {}, icon: Icon(Icons.pause), color: Colors.white),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.play_arrow),
                  color: Colors.white,
                ),
                // IconButton(onPressed: () {}, icon: Icon(Icons.stop), color: Colors.white),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.forward_5),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.navigate_next),
                  color: Colors.white,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.volume_up),
                  color: Colors.white,
                ),
                // IconButton(
                // onPressed: () {},
                // icon: Icon(Icons.volume_mute),
                // color: Colors.white,
                // ),
                Slider(
                  value: 0.5,
                  onChanged: (value) {},
                  thumbColor: Colors.white,
                  activeColor: Colors.white70,
                  inactiveColor: Colors.white10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
