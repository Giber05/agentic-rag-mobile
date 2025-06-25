import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/loading/circular_progress.dart';
import 'package:mobile_app/core/widgets/loading/loading_text.dart';

class FUICircularProgressText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Duration? loadingDuration;
  final int numberOfDots;
  final Color? circularColor;
  final double? radius;
  final double textToCircularSpacing;
  const FUICircularProgressText(
      {super.key,
      required this.text,
      this.textStyle,
      this.loadingDuration,
      this.numberOfDots = 3,
      this.circularColor,
      this.radius,
      this.textToCircularSpacing = 12});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FUICircularLoading(
          color: circularColor,
          radius: radius,
        ),
        SizedBox(height: textToCircularSpacing),
        FUILoadingText(text,
            loadingDuration: loadingDuration ?? const Duration(seconds: 500),
            numberOfDots: numberOfDots,
            style: textStyle)
      ],
    );
  }
}
