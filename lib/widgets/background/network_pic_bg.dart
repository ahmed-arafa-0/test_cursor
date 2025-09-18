import 'package:flutter/material.dart';

class NetworkPictureBackground extends StatelessWidget {
  const NetworkPictureBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://twwvmidlorzkijbneeee.supabase.co/storage/v1/object/public/assets/images/6.jpg',
          ),
          fit: BoxFit.cover, // Cover the entire screen
        ),
      ),
    );
  }
}
