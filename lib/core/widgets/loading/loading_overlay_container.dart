
import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/loading/loading_overlay.dart';
import 'package:mobile_app/core/widgets/loading/loading_overlay_container_provider.dart';
class FUILoadingContainer extends StatefulWidget {
  final Color? circularColor;
  final double? radius;
  final bool isInitialyLoading;
  final Widget child;
  final String? text;
  final TextStyle? textStyle;
  final Duration? loadingDuration;
  final int numberOfDots;
  final bool initial;
  final FUILoadingContainerController? controller;
  final double textToCircularSpacing;
  const FUILoadingContainer(
      {super.key,
      this.circularColor,
      this.radius,
      this.text,
      required this.controller,
      required this.child,
      this.initial = false,
      this.textStyle,
      this.textToCircularSpacing = 12,
      this.loadingDuration = const Duration(milliseconds: 500),
      this.numberOfDots = 5,
      this.isInitialyLoading = false});

  @override
  State<FUILoadingContainer> createState() => _FUILoadingContainerState();
}

class FUILoadingContainerController extends ValueNotifier<bool> {
  FUILoadingContainerController({bool initialValue = false})
      : super(initialValue);

  set isLoading(bool isLoading) => value = isLoading;
}

class _FUILoadingContainerState extends State<FUILoadingContainer> {
  late final FUILoadingContainerController _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.controller ??
        FUILoadingContainerController(initialValue: widget.initial);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _isLoading.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FUILoadingScope(
      toggleLoading: (value) {
        _isLoading.value = value;
      },
      child: Stack(
        children: [
          widget.child,
          ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (context, value, child) {
              return Visibility(
                visible: value,
                child: FUILoadingOverlay(
                  text: widget.text,
                  circularColor: widget.circularColor,
                  loadingDuration: widget.loadingDuration,
                  numberOfDots: widget.numberOfDots,
                  radius: widget.radius,
                  textStyle: widget.textStyle ??
                      Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  textToCircularSpacing: widget.textToCircularSpacing,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
