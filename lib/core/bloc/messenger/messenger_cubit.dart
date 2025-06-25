import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'messenger_state.dart';

@singleton
class MessengerCubit extends Cubit<MessengerState> {
  MessengerCubit() : super(MessengerIdle());

  void idle() {
    emit(MessengerIdle());
  }

  void showSuccessSnackbar(String message,
      {Duration duration = const Duration(seconds: 1)}) {
    showSnackbar(
        message: message,
        backgroundColor: (context) => Theme.of(context).colorScheme.surface,
        duration: duration,
        icon: Icons.check_circle,
        textColor: (context) => Theme.of(context).colorScheme.onSurface);
  }

  void showErrorSnackbar(String message,
      {Duration duration = const Duration(seconds: 1)}) {
    showSnackbar(
        message: message,
        backgroundColor: (context) => Theme.of(context).colorScheme.error,
        duration: duration,
        textColor: (context) => Theme.of(context).colorScheme.onError);
  }

  void showSuccessDialog(
      {String? message, String? title, bool animation = false}) {
    showDialogMessage(
      message: message,
      title: title,
      icon: Icons.check_circle,
    );
  }

  void showErrorDialog({String? message, String? title}) {
    showDialogMessage(
      message: message,
      title: title,
      icon: Icons.cancel,
      iconColor: (context) => Theme.of(context).colorScheme.error,
    );
  }

  void showDialogMessage(
      {String? message,
      String? title,
      IconData? icon,
      Widget? iconWidget,
      BuildWithContext<Color>? iconColor,
      BuildWithContext<TextStyle>? titleStyle}) {
    emit(MessengerDialog(
        title: title,
        titleStyle: titleStyle,
        message: message,
        icon: iconWidget,
        iconColor: iconColor ?? (context) => Theme.of(context).colorScheme.primary,
        iconData: icon));
  }

  void showSnackbar(
      {required String message,
      required BuildWithContext<Color> backgroundColor,
      required Duration duration,
      IconData? icon,
      required BuildWithContext<Color> textColor}) {
    emit(MessengerSnackbar(
        message: message,
        backgroundColor: backgroundColor,
        duration: duration,
        iconData: icon,
        textColor: textColor));
  }
}

extension MessageExt on BuildContext {
  MessengerCubit get messenger => read<MessengerCubit>();
}
