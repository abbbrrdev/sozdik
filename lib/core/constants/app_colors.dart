import 'package:flutter/material.dart';

/// Color palette for Сөзді тап — Kazakh Wordle
class AppColors {
  AppColors._();

  // Tile states
  static const Color correct = Color(0xFF6AAA64); // Green — right position
  static const Color present = Color(0xFFC9B458); // Yellow — wrong position
  static const Color absent = Color(0xFF787C7E); // Grey — not in word
  static const Color empty = Color(0xFFFFFFFF); // White — not yet filled
  static const Color filled = Color(0xFFFFFFFF); // White — typed but not submitted

  // Borders
  static const Color borderEmpty = Color(0xFFD3D6DA);
  static const Color borderFilled = Color(0xFF878A8C);

  // Background
  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textOnTile = Color(0xFFFFFFFF);
  static const Color textOnEmpty = Color(0xFF1A1A2E);

  // Keyboard
  static const Color keyDefault = Color(0xFFD3D6DA);
  static const Color keyText = Color(0xFF1A1A2E);
  static const Color keyTextLight = Color(0xFFFFFFFF);

  // Accent
  static const Color accent = Color(0xFF538D4E);
  static const Color accentLight = Color(0xFFE8F5E9);

  // Header
  static const Color headerBorder = Color(0xFFE5E5E5);

  // Overlay
  static const Color overlay = Color(0x80000000);

  // Toast
  static const Color toastBackground = Color(0xFF1A1A2E);
  static const Color toastText = Color(0xFFFFFFFF);
}
