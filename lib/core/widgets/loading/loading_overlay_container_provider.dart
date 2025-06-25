import 'package:flutter/material.dart';

class FUILoadingScope extends InheritedWidget {
  final ValueChanged<bool> toggleLoading;
  const FUILoadingScope({super.key, required super.child, required this.toggleLoading});

  static FUILoadingScope of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<FUILoadingScope>();
    if (widget == null) {
      throw Exception("Cant Found Color Provider in the tree");
    }
    return widget;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

extension LoadingScopeExt on BuildContext {
  FUILoadingScope get loadingScope => FUILoadingScope.of(this);
  set loading(bool value) {
    loadingScope.toggleLoading(value);
  }
}
