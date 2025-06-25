import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FUICircularLoading extends StatelessWidget {
  final Color? color;
  final double? radius;
  const FUICircularLoading({super.key, this.color, this.radius});

  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(
      radius: radius ?? 20,
      color: color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
