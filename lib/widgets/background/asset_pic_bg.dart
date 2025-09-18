import 'package:flutter/material.dart';

import '../../utils/defaults.dart';

class AssetPictureBackground extends StatelessWidget {
  const AssetPictureBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(defaultPicturePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
