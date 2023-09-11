import 'package:flutter/material.dart';

class ProfileActionButton extends StatelessWidget {
  Color buttonColor;
  Color buttonBorder;
  String buttonLabel;
  Function()? action;

  ProfileActionButton({
    super.key,
    required this.buttonLabel,
    required this.buttonColor,
    required this.buttonBorder,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.all(5),
        width: 250,
        decoration: BoxDecoration(
          color: buttonColor,
          border: Border.all(
            color: buttonBorder,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            buttonLabel,
          ),
        ),
      ),
    );
  }
}
