import 'package:flutter/material.dart';

import '../../../../core/utils/responsive_utils.dart';

/// Manages responsive layouts for the assistant page
/// Reduces code duplication and centralizes layout logic
class AssistantLayoutManager extends StatelessWidget {
  final Widget appBar;
  final Widget conversationArea;
  final Widget inputArea;

  const AssistantLayoutManager({
    super.key,
    required this.appBar,
    required this.conversationArea,
    required this.inputArea,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  /// Mobile layout: vertical stack with full-width conversation area
  Widget _buildMobileLayout() {
    return Column(children: [appBar, Expanded(child: conversationArea), inputArea]);
  }

  /// Tablet layout: similar to mobile but with potential for side panels
  Widget _buildTabletLayout() {
    return Column(
      children: [
        appBar,
        Expanded(
          child: Row(
            children: [
              Expanded(child: conversationArea),
              // Future: Add side panel for tablet-specific features
            ],
          ),
        ),
        inputArea,
      ],
    );
  }

  /// Desktop layout: optimized for larger screens with enhanced features
  Widget _buildDesktopLayout() {
    return Column(children: [appBar, Expanded(child: conversationArea), inputArea]);
  }
}
