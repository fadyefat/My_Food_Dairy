import 'package:flutter/material.dart';

class AppColors {
  // Primary & Backgrounds
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreenBackground = Color.fromRGBO(196, 228, 210, 1.0);
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color cardLightGreen = Color(0xFFE8F5E8);
  static const Color white = Colors.white;

  // Accents & Actions
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color lightOrange = Color(0xFFFFF3E0);
  static const Color orangeBorder = Color(0xFFFFCC80);

  // Text Colors
  static const Color darkText = Color(0xFF333333);
  static const Color greyText = Color(0xFF757575);
  static const Color lightGreyText = Color(0xFF9E9E9E);
  static Color darkGreenText = Colors.green.shade900;

  // Borders & Dividers
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color cardShadow = Color(0x0D000000);

  // Meal Type Colors
  static Color breakfastColor = Colors.orange.shade600;
  static Color lunchColor = Colors.green.shade600;
  static Color dinnerColor = Colors.blue.shade600;
  static Color snackColor = Colors.purple.shade600;
  static Color defaultMealColor = Colors.grey.shade600;

  static Color getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return breakfastColor;
      case 'lunch':
        return lunchColor;
      case 'dinner':
        return dinnerColor;
      case 'snack':
        return snackColor;
      default:
        return defaultMealColor;
    }
  }
}
