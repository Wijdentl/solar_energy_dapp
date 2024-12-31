import 'package:flutter/material.dart';
import 'package:solar_energy_dapp/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final bool disabled;
  final EdgeInsets? padding;
  final VoidCallback onPressed;

  const CustomButton(
      {Key? key,
      required this.label,
      this.disabled = false,
      this.padding,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: disabled ? null : onPressed,
        style: TextButton.styleFrom(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 20),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            backgroundColor: disabled ? Colors.black12 : themeColorDarkest),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ));
  }
}