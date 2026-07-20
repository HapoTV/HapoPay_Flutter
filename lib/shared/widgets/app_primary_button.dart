import "package:flutter/material.dart";

import "../../core/constants/constants.dart";

// ignore: must_be_immutable
class AppPrimaryButtonWidget extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  bool isLoading;
  bool isDisabled;

  AppPrimaryButtonWidget({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: isLoading == true
          ? const CircularProgressIndicator()
          : MaterialButton(
              onPressed: isDisabled == true
                  ? null
                  : onTap, // Implement login functionality
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge!.copyWith(
                      color: theme.colorScheme.inverseSurface,
                    ),
                  ),
                  horizontalSpaceTiny,
                  Icon(icon, color: Colors.white),
                ],
              ),
            ),
    );
  }
}
