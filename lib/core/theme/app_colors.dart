import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary Brand Colors
  static const Color primary = Color(0xFF3F51B5); // Deep Indigo
  static const Color primaryDark = Color(0xFF303F9F);
  static const Color primaryLight = Color(0xFFC5CAE9);
  
  static const Color secondary = Color(0xFF455A64); // Slate Grey
  static const Color secondaryLight = Color(0xFFCFD8DC);
  
  // Neutral Colors (Backgrounds, Cards, Text)
  static const Color background = Color(0xFFF8F9FA); // Very light grey/white
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);
  
  // Status Colors (Priority & Ticket Status)
  static const Color statusNew = Color(0xFF2196F3); // Blue
  static const Color statusInProgress = Color(0xFFFF9800); // Amber/Orange
  static const Color statusResolved = Color(0xFF4CAF50); // Green
  static const Color statusClosed = Color(0xFF9E9E9E); // Grey
  
  // Priority Colors
  static const Color priorityLow = Color(0xFF8BC34A); // Light Green
  static const Color priorityMedium = Color(0xFFFBC02D); // Deep Yellow
  static const Color priorityHigh = Color(0xFFF44336); // Red
  static const Color priorityUrgent = Color(0xFFB71C1C); // Dark Red
  
  // Common Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
}
