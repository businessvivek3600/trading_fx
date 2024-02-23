import 'package:flutter/material.dart';

import '../../utils/text.dart';
import '../utils/default_logger.dart';
import '../utils/sizedbox_utils.dart';

enum ButtonLoadingState { idle, loading, completed, failed }

class MultiStageButton extends StatelessWidget {
  MultiStageButton({
    super.key,
    required this.buttonLoadingState,
    this.enableCondition,
    required this.onPressed,
    this.idleColor,
    this.completedColor = Colors.green,
    this.failColor = Colors.red,
    this.loadingColor = Colors.grey,
    this.loadingTextColor,
    this.failTextColor,
    this.completedTextColor,
    this.idleTextColor,
    this.idleText = 'Proceed',
    this.completedText = 'Completed',
    this.failedText = 'Failed',
    this.helperText,
    this.loadingText,
    this.loadingIcon,
    this.idleIcon,
    this.failedIcon,
    this.completedIcon,
    this.iconMode = false,
  });
  final ButtonLoadingState buttonLoadingState;
  final bool? enableCondition;
  final VoidCallback onPressed;
  final Color? idleColor;
  final Color completedColor;
  final Color failColor;
  final Color loadingColor;
  final Color? idleTextColor;
  final Color? completedTextColor;
  final Color? failTextColor;
  final Color? loadingTextColor;
  String? idleText;
  String? completedText;
  String? failedText;
  String? loadingText;
  String? helperText;
  final Widget? loadingIcon;
  final Widget? idleIcon;
  final Widget? failedIcon;
  final Widget? completedIcon;
  final bool iconMode;
  @override
  Widget build(BuildContext context) {
    infoLog('Button state is $buttonLoadingState');
    if (iconMode) {
      loadingText = null;
      idleText = null;
      completedText = null;
      failedText = null;
    }
    Color? textColor = buttonLoadingState == ButtonLoadingState.completed
        ? completedTextColor
        : buttonLoadingState == ButtonLoadingState.idle
            ? idleTextColor
            : buttonLoadingState == ButtonLoadingState.failed
                ? failTextColor
                : loadingTextColor;
    var _onPressed =
        enableCondition ?? (buttonLoadingState != ButtonLoadingState.loading)
            ? () {
                if (buttonLoadingState == ButtonLoadingState.idle) {
                  onPressed();
                }
              }
            : null;
    Color? backgroundColor = buttonLoadingState == ButtonLoadingState.completed
        ? completedColor
        : buttonLoadingState == ButtonLoadingState.idle
            ? idleColor
            : buttonLoadingState == ButtonLoadingState.failed
                ? failColor
                : loadingColor;
    var style = ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
    var child = buttonLoadingState == ButtonLoadingState.loading
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                  width: 30,
                  height: 30,
                  child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))),
              if (loadingText != null)
                Row(
                  children: [
                    width10(),
                    Expanded(
                      child: bodyLargeText(loadingText!, context,
                          color: textColor ?? Colors.white, maxLines: 1),
                    ),
                  ],
                )
            ],
          )
        : buttonLoadingState == ButtonLoadingState.failed
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (failedIcon != null)
                    Row(
                      children: [
                        failedIcon!,
                        width5(),
                      ],
                    ),
                  if (failedText != null)
                    Expanded(
                      child: bodyLargeText(failedText!, context,
                          color: textColor ?? Colors.white, maxLines: 1),
                    )
                ],
              )
            : buttonLoadingState == ButtonLoadingState.completed
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (completedIcon != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(child: completedIcon!),
                            if (completedText != null) width5(),
                          ],
                        ),
                      if (completedText != null)
                        Expanded(
                          child: bodyLargeText(completedText!, context,
                              color: textColor ?? Colors.white, maxLines: 1),
                        )
                    ],
                  )
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (idleIcon != null)
                      Row(
                        children: [
                          idleIcon!,
                          width5(),
                        ],
                      ),
                    if (idleText != null)
                      Expanded(
                        child: titleLargeText(idleText!, context,
                            color: textColor ?? Colors.white, maxLines: 1),
                      ),
                  ]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        iconMode
            ? FloatingActionButton(
                elevation: 0,
                onPressed: _onPressed,
                backgroundColor: backgroundColor,
                child: child)
            : FilledButton(onPressed: _onPressed, style: style, child: child),
        if (helperText != null)
          capText(
            helperText!,
            context,
            color: buttonLoadingState == ButtonLoadingState.completed
                ? completedTextColor ?? completedColor
                : buttonLoadingState == ButtonLoadingState.idle
                    ? idleTextColor ?? idleColor
                    : buttonLoadingState == ButtonLoadingState.failed
                        ? failTextColor ?? failColor
                        : loadingTextColor ?? loadingColor,
          )
      ],
    );
  }
}
