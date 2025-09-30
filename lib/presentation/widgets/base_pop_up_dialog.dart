import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BasePopUpDialog extends StatelessWidget {
  final String question;
  final String yesText;
  final String noText;
  final VoidCallback onYesPressed;
  final VoidCallback onNoPressed;
  final bool autoPopOnPressed;

  const BasePopUpDialog({
    super.key,
    required this.question,
    required this.yesText,
    required this.noText,
    required this.onYesPressed,
    required this.onNoPressed,
    this.autoPopOnPressed = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Konfirmasi'),
      content: Text(question, style: Theme.of(context).textTheme.labelMedium),
      actions: <Widget>[
        TextButton(
          child: Text(
            noText,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 12.w,
              color: Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () {
            onNoPressed();
            if (autoPopOnPressed) {
              Navigator.of(context).pop();
            }
          },
        ),
        TextButton(
          child: Text(
            yesText,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 12.w,
              color: Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () {
            onYesPressed();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
