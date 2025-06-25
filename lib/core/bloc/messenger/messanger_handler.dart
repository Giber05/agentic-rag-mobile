import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/bloc/messenger/messenger_cubit.dart';
import 'package:mobile_app/core/widgets/dialogs/dialog_with_top_icon_centered.dart';

class FUIMessengerHandler {
  static Future<void> handle(BuildContext context, MessengerState state) async {
    switch (state) {
      case MessengerSnackbar():
        await handleSnackbar(context, state);
      case MessengerDialog():
        await handleDialog(context, state);
      default:
    }
  }

  static Future<void> handleDialog(BuildContext context, MessengerDialog state) async {
    final title = state.title;
    final icon = state.iconData;
    final message = state.message;

    await showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: true,
      builder: (context) => DialogWithTopCenterIcon(
        title: title,
        description: message,
        centeredTitle: true,
        color: state.iconColor?.call(context),
        image: state.icon ??
            (icon != null
                ? Icon(icon, size: 24, color: Colors.white)
                : null),
        buttonText: 'OK',
        onButtonTextPressed: () {
          context.router.maybePop();
        },
      ),
    );
  }

  static Future<void> handleSnackbar(BuildContext context, MessengerSnackbar state) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: state.duration,
      content: Row(
        children: [
          Expanded(
            child: Text(state.message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: state.textColor(context))),
          ),
          if (state.iconData != null)
            Icon(state.iconData!, color: state.textColor(context))
        ],
      ),
      backgroundColor: state.backgroundColor(context),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
