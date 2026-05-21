import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Shared app text field wrapper.
class AppTextField extends StatelessWidget {
  /// Creates a text field.
  const AppTextField({
    required this.controller,
    required this.labelText,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.suffixIcon,
    super.key,
  });

  /// Controller for the field.
  final TextEditingController controller;

  /// Label text.
  final String labelText;

  /// Hint text.
  final String? hintText;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Whether to obscure text.
  final bool obscureText;

  /// Form validator.
  final String? Function(String?)? validator;

  /// Input action.
  final TextInputAction? textInputAction;

  /// Callback when the field is submitted from the keyboard.
  final ValueChanged<String>? onFieldSubmitted;

  /// Trailing icon.
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.inputHeight + AppDimensions.spaceXXL,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
