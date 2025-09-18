import 'package:flutter/material.dart';

class SignatureText extends StatelessWidget {
  const SignatureText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "♈AR",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'MrDeHaviland',
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
