
import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/loading/circular_progress.dart';
import 'package:mobile_app/core/widgets/loading/circular_progress_text.dart';

class FUILoadingOverlay extends StatelessWidget {
  final Color? circularColor;
  final double? radius;
  final bool isInitialyLoading;
  final String? text;
  final TextStyle? textStyle;
  final Duration? loadingDuration;
  final int numberOfDots;
  final double textToCircularSpacing;
  const FUILoadingOverlay(
      {super.key,
      this.circularColor,
      this.radius,
      this.text,
      this.textStyle,
      this.textToCircularSpacing = 12,
      this.loadingDuration = const Duration(milliseconds: 500),
      this.numberOfDots = 5,
      this.isInitialyLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withAlpha((0.5 * 255).floor()),
      alignment: Alignment.center,
      child: text != null
          ? FUICircularProgressText(
              text: text!,
              circularColor: circularColor,
              loadingDuration: loadingDuration,
              numberOfDots: numberOfDots,
              radius: radius,
              textStyle: textStyle,
              textToCircularSpacing: textToCircularSpacing,
            )
          : Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FUICircularLoading(
                  color: circularColor ?? Theme.of(context).colorScheme.primary,
                  radius: radius ?? 16,
                ),
              ),
            ),
    );
  }
}
