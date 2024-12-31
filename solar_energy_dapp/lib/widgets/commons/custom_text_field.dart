import 'package:flutter/material.dart';
import 'package:solar_energy_dapp/constants/colors.dart';

class CustomTextField extends StatelessWidget {
  final String? placeholder;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool hideText;
  final TextEditingController? controller;
  final bool valid;
  final String? errorText;

  const CustomTextField(
      {Key? key,
      this.valid = true,
      this.errorText,
      this.suffixIcon,
      this.controller,
      this.hideText = false,
      this.placeholder,
      this.prefixIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: hideText,
      decoration: InputDecoration(
          errorText: valid ? null : errorText,
          suffixIcon: suffixIcon,
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: errorThemeColor),
              borderRadius: BorderRadius.all(Radius.circular(30))),
          focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: errorThemeColor),
              borderRadius: BorderRadius.all(Radius.circular(30))),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: themeColorDarkest),
              borderRadius: BorderRadius.all(Radius.circular(30))),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: themeColorDarkest, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(30))),
          disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(30))),
          hintText: placeholder,
          prefixIcon: prefixIcon),
    );
  }
}