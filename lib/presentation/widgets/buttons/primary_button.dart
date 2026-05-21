import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Shared primary button with loading support.
class PrimaryButton extends StatelessWidget {
  /// Creates a primary button.
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  /// Button label.
  final String label;

  /// Button callback.
  final VoidCallback? onPressed;

  /// Whether to show the loading state.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: AppDimensions.iconLG,
                height: AppDimensions.iconLG,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
