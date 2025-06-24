import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes and breakpoints
class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  /// Get current device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Check if current device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Get responsive padding based on device type
  static EdgeInsets getResponsivePadding(BuildContext context, {double? mobile, double? tablet, double? desktop}) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return EdgeInsets.all(mobile ?? 16.0);
      case DeviceType.tablet:
        return EdgeInsets.all(tablet ?? 24.0);
      case DeviceType.desktop:
        return EdgeInsets.all(desktop ?? 32.0);
    }
  }

  /// Get responsive horizontal padding based on device type
  static EdgeInsets getResponsiveHorizontalPadding(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return EdgeInsets.symmetric(horizontal: mobile ?? 20.0);
      case DeviceType.tablet:
        return EdgeInsets.symmetric(horizontal: tablet ?? 40.0);
      case DeviceType.desktop:
        return EdgeInsets.symmetric(horizontal: desktop ?? 80.0);
    }
  }

  /// Get responsive font size based on device type
  static double getResponsiveFontSize(BuildContext context, {double? mobile, double? tablet, double? desktop}) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? 14.0;
      case DeviceType.tablet:
        return tablet ?? 16.0;
      case DeviceType.desktop:
        return desktop ?? 18.0;
    }
  }

  /// Get maximum content width for centering on larger screens
  static double getMaxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 800.0;
      case DeviceType.desktop:
        return 1200.0;
    }
  }

  /// Get responsive grid cross axis count
  static int getGridCrossAxisCount(BuildContext context, {int? mobile, int? tablet, int? desktop}) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? 1;
      case DeviceType.tablet:
        return tablet ?? 2;
      case DeviceType.desktop:
        return desktop ?? 3;
    }
  }

  /// Get responsive spacing value
  static double getResponsiveSpacing(BuildContext context, {double? mobile, double? tablet, double? desktop}) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? 8.0;
      case DeviceType.tablet:
        return tablet ?? 12.0;
      case DeviceType.desktop:
        return desktop ?? 16.0;
    }
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, {double? mobile, double? tablet, double? desktop}) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? 12.0;
      case DeviceType.tablet:
        return tablet ?? 16.0;
      case DeviceType.desktop:
        return desktop ?? 20.0;
    }
  }

  /// Get conversation layout configuration
  static ConversationLayout getConversationLayout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return ConversationLayout(
        showSidebar: false,
        maxMessageWidth: double.infinity,
        messageHorizontalPadding: 16.0,
        inputBottomPadding: 20.0,
      );
    } else if (width < tabletBreakpoint) {
      return ConversationLayout(
        showSidebar: false,
        maxMessageWidth: 600.0,
        messageHorizontalPadding: 32.0,
        inputBottomPadding: 24.0,
      );
    } else {
      return ConversationLayout(
        showSidebar: true,
        maxMessageWidth: 800.0,
        messageHorizontalPadding: 48.0,
        inputBottomPadding: 32.0,
      );
    }
  }
}

/// Device type enumeration
enum DeviceType { mobile, tablet, desktop }

/// Conversation layout configuration
class ConversationLayout {
  final bool showSidebar;
  final double maxMessageWidth;
  final double messageHorizontalPadding;
  final double inputBottomPadding;

  const ConversationLayout({
    required this.showSidebar,
    required this.maxMessageWidth,
    required this.messageHorizontalPadding,
    required this.inputBottomPadding,
  });
}

/// Responsive widget builder that provides different widgets based on device type
class ResponsiveBuilder extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? fallback;

  const ResponsiveBuilder({super.key, this.mobile, this.tablet, this.desktop, this.fallback});

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? tablet ?? desktop ?? fallback ?? Container();
      case DeviceType.tablet:
        return tablet ?? desktop ?? mobile ?? fallback ?? Container();
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile ?? fallback ?? Container();
    }
  }
}

/// Responsive value helper that returns different values based on device type
class ResponsiveValue<T> {
  final T? mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({this.mobile, this.tablet, this.desktop});

  T? getValue(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? tablet ?? desktop;
      case DeviceType.tablet:
        return tablet ?? desktop ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}
