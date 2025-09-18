import 'package:flutter/material.dart';
import 'package:test_cursor/widgets/content/counter.dart';
import 'package:test_cursor/widgets/content/quote.dart';
import 'package:test_cursor/widgets/content/title.dart';

import 'signature.dart';

class ContentBox extends StatelessWidget {
  const ContentBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 64.0),
      // width: 400,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black87,
      ),
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TitleText(),
              CounterText(),
              QuoteText(),
              SignatureText(),
            ],
          ),
        ),
      ),
    );
  }
}
