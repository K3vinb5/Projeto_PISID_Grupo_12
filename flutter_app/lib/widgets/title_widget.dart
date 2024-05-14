import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget(
      {Key? key, required this.titleGap, required this.titleText});

  final double titleGap;
  final String titleText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: titleGap,
        ),
        Text(
          titleText,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          width: titleGap,
        ),
      ],
    );
  }
}
