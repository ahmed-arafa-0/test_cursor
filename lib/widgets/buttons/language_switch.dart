import 'package:flutter/material.dart';

class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18.0,
      backgroundColor: Colors.black45,
      child: IconButton(
        onPressed: () {},
        icon: Icon(Icons.language, size: 20),
        color: Colors.white,
      ),
    );
  }
}
