import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Стили текста Dreem World.
class AppTextStyles {
  const AppTextStyles._();

  static const String _family = 'Roboto';

  static TextStyle display({Color color = AppColors.textPrimary}) => TextStyle(
    fontFamily: _family,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
    color: color,
  );

  static TextStyle headline({Color color = AppColors.textPrimary}) => TextStyle(
    fontFamily: _family,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: color,
  );

  static TextStyle title({Color color = AppColors.textPrimary}) => TextStyle(
    fontFamily: _family,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: color,
  );

  static TextStyle body({Color color = AppColors.textPrimary}) => TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: color,
  );

  static TextStyle bodyBold({Color color = AppColors.textPrimary}) => TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.45,
    color: color,
  );

  static TextStyle label({Color color = AppColors.textPrimary}) => TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.4,
    color: color,
  );

  static TextStyle caption({Color color = AppColors.textSecondary}) =>
      TextStyle(
        fontFamily: _family,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: color,
      );
}
