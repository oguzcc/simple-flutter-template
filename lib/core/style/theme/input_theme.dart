import 'package:flutter/material.dart';

InputDecorationTheme buildInputDecorationTheme(ColorScheme colorScheme) {
  OutlineInputBorder border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecorationTheme(
    filled: true,
    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: border(colorScheme.outline),
    enabledBorder: border(colorScheme.outlineVariant),
    focusedBorder: border(colorScheme.primary, width: 2),
    errorBorder: border(colorScheme.error),
    focusedErrorBorder: border(colorScheme.error, width: 2),
    disabledBorder: border(colorScheme.outlineVariant.withValues(alpha: 0.4)),
    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
    hintStyle: TextStyle(
      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
    ),
    errorStyle: TextStyle(color: colorScheme.error),
    prefixIconColor: colorScheme.onSurfaceVariant,
    suffixIconColor: colorScheme.onSurfaceVariant,
  );
}
