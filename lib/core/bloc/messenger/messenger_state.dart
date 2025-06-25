part of 'messenger_cubit.dart';

typedef BuildWithContext<T> = T Function(BuildContext context);

sealed class MessengerState extends Equatable {
  const MessengerState();

  @override
  List<Object?> get props => [];
}

class MessengerIdle extends MessengerState {}

class MessengerDialog extends MessengerState {
  final String? message;

  final String? title;
  final BuildWithContext<TextStyle>? titleStyle;
  final BuildWithContext<Color>? iconColor;
  final IconData? iconData;
  final Widget? icon;

  const MessengerDialog(
      {this.message,
      required this.title,
      this.titleStyle,
      this.iconData,
      this.icon,
      this.iconColor});

  @override
  List<Object?> get props => [message, iconData, titleStyle, title, iconColor];
}

class MessengerSnackbar extends MessengerState {
  final String message;
  final BuildWithContext<Color> backgroundColor;
  final BuildWithContext<Color> textColor;
  final Duration duration;
  final IconData? iconData;

  const MessengerSnackbar(
      {required this.message,
      required this.backgroundColor,
      required this.duration,
      this.iconData,
      required this.textColor});

  @override
  List<Object?> get props => [message, iconData];
}
