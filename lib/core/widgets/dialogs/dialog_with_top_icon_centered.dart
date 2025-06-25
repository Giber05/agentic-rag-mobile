import 'package:flutter/material.dart';

class DialogWithTopCenterIcon extends StatelessWidget {
  final String? title, description;
  final String? buttonText;
  final Widget? image;
  final Color? color;
  final VoidCallback? onConfirmed;
  final VoidCallback? onCanceled;
  final VoidCallback? onButtonTextPressed;
  final bool centeredTitle;
  final String? onConfirmText;
  final Widget Function(BuildContext context)? builder;
  final String? onCanceledText;
  final double? dialogMargin;
  final EdgeInsets? insetPadding;

  const DialogWithTopCenterIcon({
    super.key,
    this.title,
    this.description,
    this.buttonText,
    this.centeredTitle = false,
    this.image,
    this.color,
    this.onConfirmed,
    this.onCanceled,
    this.onButtonTextPressed,
    this.onCanceledText,
    this.builder,
    this.onConfirmText,
    this.dialogMargin,
    this.insetPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: insetPadding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 32 + 16, bottom: 16, left: 16, right: 16),
          margin: EdgeInsets.only(top: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0))],
          ),
          child:
              builder != null
                  ? builder!(context)
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    // To make the card compact
                    children: <Widget>[
                      if (title != null)
                        Text(
                          title!,
                          textAlign: centeredTitle ? TextAlign.center : TextAlign.start,
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
                        ),
                      SizedBox(height: 16.0),
                      if (description != null)
                        Text(description!, textAlign: TextAlign.center, style: TextStyle(height: 1.5, fontSize: 14.0)),
                      SizedBox(height: 24.0),
                      (onConfirmed == null || onCanceled == null)
                          ? Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onButtonTextPressed?.call();
                              },
                              child: Text(
                                "${buttonText?.toUpperCase()}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () {
                                  if (onCanceled != null) {
                                    onCanceled?.call();
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text(
                                  onCanceledText.toString(),
                                  style: TextStyle(fontSize: 14, color: Color(0xffDD4E10), fontWeight: FontWeight.w600),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  onConfirmed?.call();
                                },
                                child: Text(
                                  onConfirmText.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
        ),
        Positioned(
          left: 16,
          right: 16,
          child: CircleAvatar(
            backgroundColor: color ?? Theme.of(context).colorScheme.primary,
            radius: 32,
            child: image ?? Icon(Icons.done, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
