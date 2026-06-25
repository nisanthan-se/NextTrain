import 'package:flutter/material.dart';

extension ColorValues on Color {
  /// Lightweight helper used across the app to set opacity.
  /// Example: `Colors.white.withValues(alpha: 0.05)`
  Color withValues({double? alpha}) {
    if (alpha != null) return withOpacity(alpha);
    return this;
  }
}
