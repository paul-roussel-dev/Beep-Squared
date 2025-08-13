import 'package:flutter/material.dart';

/// Application sizing and spacing constants
class AppSizes {
  AppSizes._();

  // === SPACING (multiples of 8dp) ===
  static const double spacingXs = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // === ICON SIZES ===
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 64.0;

  // === BORDER RADIUS ===
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusCircular = 20.0;

  // === CARD DIMENSIONS ===
  static const double cardPadding = spacingMedium;
  static const double cardMargin = spacingSmall;
  static const double cardElevation = 4.0;
  static const double fabElevation = 6.0;

  // === BUTTON DIMENSIONS ===
  static const double buttonHeight = 48.0;
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 16.0;

  // === LAYOUT DIMENSIONS ===
  static const double appBarElevation = 0.0;
  static const double fabSpacing = 100.0; // Space for FAB

  // === WIDGETS (Prebuilt widgets for consistency) ===
  // SizedBox gaps
  static const Widget gapSmall = SizedBox(
    width: spacingSmall,
    height: spacingSmall,
  );
  static const Widget gapMedium = SizedBox(
    width: spacingMedium,
    height: spacingMedium,
  );
  static const Widget gapLarge = SizedBox(
    width: spacingLarge,
    height: spacingLarge,
  );
  static const double maxContentWidth = 600.0;

  // === COMMON EDGE INSETS ===
  static const EdgeInsets paddingAll = EdgeInsets.all(16.0);
  static const EdgeInsets paddingAllLarge = EdgeInsets.all(24.0);
  static const EdgeInsets paddingAllXl = EdgeInsets.all(32.0);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(
    horizontal: 16.0,
  );
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(
    vertical: 16.0,
  );
  static const EdgeInsets paddingCard = EdgeInsets.all(16.0);
  static const EdgeInsets marginCard = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 4.0,
  );
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 16.0,
  );
}
