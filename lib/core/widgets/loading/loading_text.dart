import 'dart:async';

import 'package:flutter/material.dart';

class FUILoadingText extends StatefulWidget {
  final String data;
  final TextStyle? style;
  final Duration loadingDuration;
  final int numberOfDots;
  const FUILoadingText(this.data,
      {super.key,
      this.style,
      this.loadingDuration = const Duration(milliseconds: 500),
      this.numberOfDots = 5});

  @override
  // ignore: library_private_types_in_public_api
  _FUILoadingTextState createState() => _FUILoadingTextState();
}

class _FUILoadingTextState extends State<FUILoadingText> {
  Timer? _debounce;

  var text = "";
  var currentLoop = 0;

  @override
  void initState() {
    text = widget.data;
    _debounce = Timer.periodic(widget.loadingDuration, (_) {
      if (currentLoop < widget.numberOfDots) {
        text += " .";
        currentLoop++;
      } else {
        currentLoop = 0;
        text = widget.data;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: widget.style,
    );
  }
}
