import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Уплотнённая сетка для внутреннего экрана планеты.
///
/// Значения примерно вдвое меньше обычных, чтобы карточки, отступы и картинки
/// занимали меньше места на странице.
class CompactSpace {
  const CompactSpace._();

  static const double xxs = 1;
  static const double xs = 2;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;

  static const EdgeInsets page = EdgeInsets.all(8);
  static const EdgeInsets card = EdgeInsets.all(8);
}

/// Уплотнённые текстовые стили для внутреннего экрана планеты.
class CompactText {
  const CompactText._();

  static TextStyle headline({Color color = AppColors.textPrimary}) =>
      AppTextStyles.title(color: color).copyWith(fontSize: 14, height: 1.2);

  static TextStyle title({Color color = AppColors.textPrimary}) =>
      AppTextStyles.title(color: color).copyWith(fontSize: 11, height: 1.2);

  static TextStyle body({Color color = AppColors.textPrimary}) =>
      AppTextStyles.body(color: color).copyWith(fontSize: 10, height: 1.3);

  static TextStyle bodyBold({Color color = AppColors.textPrimary}) =>
      AppTextStyles.bodyBold(color: color).copyWith(fontSize: 10, height: 1.3);

  static TextStyle label({Color color = AppColors.textPrimary}) =>
      AppTextStyles.label(color: color).copyWith(fontSize: 9, letterSpacing: 0);

  static TextStyle caption({Color color = AppColors.textSecondary}) =>
      AppTextStyles.caption(color: color).copyWith(fontSize: 8, height: 1.2);
}

/// Переключатель между обычными и уплотнёнными токенами.
class UiTokens {
  const UiTokens({this.compact = false});

  final bool compact;

  double get xxs => compact ? CompactSpace.xxs : AppSpacing.xxs;
  double get xs => compact ? CompactSpace.xs : AppSpacing.xs;
  double get sm => compact ? CompactSpace.sm : AppSpacing.sm;
  double get md => compact ? CompactSpace.md : AppSpacing.md;
  double get lg => compact ? CompactSpace.lg : AppSpacing.lg;
  double get xl => compact ? CompactSpace.xl : AppSpacing.xl;
  double get xxl => compact ? CompactSpace.xxl : AppSpacing.xxl;

  EdgeInsetsGeometry get page => compact ? CompactSpace.page : AppSpacing.page;
  EdgeInsetsGeometry get card => compact ? CompactSpace.card : AppSpacing.card;

  TextStyle headline({Color color = AppColors.textPrimary}) => compact
      ? CompactText.headline(color: color)
      : AppTextStyles.headline(color: color);

  TextStyle title({Color color = AppColors.textPrimary}) =>
      compact ? CompactText.title(color: color) : AppTextStyles.title(color: color);

  TextStyle body({Color color = AppColors.textPrimary}) =>
      compact ? CompactText.body(color: color) : AppTextStyles.body(color: color);

  TextStyle bodyBold({Color color = AppColors.textPrimary}) => compact
      ? CompactText.bodyBold(color: color)
      : AppTextStyles.bodyBold(color: color);

  TextStyle label({Color color = AppColors.textPrimary}) =>
      compact ? CompactText.label(color: color) : AppTextStyles.label(color: color);

  TextStyle caption({Color color = AppColors.textSecondary}) =>
      compact ? CompactText.caption(color: color) : AppTextStyles.caption(color: color);
}
