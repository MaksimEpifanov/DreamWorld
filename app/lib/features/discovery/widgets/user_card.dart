import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/index.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/index.dart';
import '../../../data/models/relationship_status.dart';

/// Карточка кандидата в подборе: крупное фото, имя/возраст, город,
/// статус отношений, интересы, круговой индикатор совместимости и
/// круглые кнопки действий.
class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.profile,
    required this.compatibility,
    this.relationshipStatus = RelationshipStatus.unspecified,
    this.isBusy = false,
    this.onLike,
    this.onPass,
    this.onReport,
  });

  final Profile profile;

  /// Процент совместимости (0–100) из AiService.
  final int compatibility;

  /// Публичный статус отношений участника.
  final RelationshipStatus relationshipStatus;

  /// Блокирует кнопки во время запроса.
  final bool isBusy;

  final VoidCallback? onLike;
  final VoidCallback? onPass;

  /// Колбэк жалобы на профиль (кнопка «Пожаловаться»).
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return NeonCard(
          color: primary,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _PhotoBanner(profile: profile, compatibility: compatibility),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: _RelationshipBadge(status: relationshipStatus),
                        ),
                        const Spacer(),
                        if (onReport != null)
                          IconButton(
                            tooltip: 'Пожаловаться',
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.flag_outlined, size: 20),
                            color: AppColors.textMuted,
                            onPressed: onReport,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if ((profile.city ?? '').isNotEmpty) ...<Widget>[
                      _City(city: profile.city!),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if ((profile.bio ?? '').isNotEmpty) ...<Widget>[
                      Text(
                        profile.bio!,
                        style: AppTextStyles.body(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (profile.interests.isNotEmpty)
                      _Interests(interests: profile.interests, color: primary),
                    const SizedBox(height: AppSpacing.lg),
                    _Actions(isBusy: isBusy, onLike: onLike, onPass: onPass),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }
}

/// Бейдж статуса отношений участника.
class _RelationshipBadge extends StatelessWidget {
  const _RelationshipBadge({required this.status});

  final RelationshipStatus status;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color color =
        status == RelationshipStatus.married ||
            status == RelationshipStatus.inRelationship
        ? scheme.tertiary
        : scheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(status.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              status.label,
              style: AppTextStyles.label(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _City extends StatelessWidget {
  const _City({required this.city});

  final String city;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: <Widget>[
        Icon(Icons.location_on_outlined, size: 16, color: primary),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            city,
            style: AppTextStyles.caption(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Крупное фото с затемнением, именем/возрастом и индикатором совместимости.
class _PhotoBanner extends StatelessWidget {
  const _PhotoBanner({required this.profile, required this.compatibility});

  final Profile profile;
  final int compatibility;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Uint8List? photoBytes = decodeDataUri(profile.photoUrl);
    final double photoHeight = (MediaQuery.sizeOf(context).height * 0.42).clamp(
      240.0,
      520.0,
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.lg),
      ),
      child: SizedBox(
        height: photoHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (photoBytes != null)
              Image.memory(photoBytes, fit: BoxFit.cover)
            else
              _Placeholder(profile: profile),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Colors.transparent, Color(0xE6080510)],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: _Nameplate(profile: profile),
            ),
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: _CompatibilityRing(
                compatibility: compatibility,
                color: scheme.primary,
              ),
            ),
            if (profile.isOnline)
              const Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: _OnlineBadge(),
              ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            scheme.primary.withValues(alpha: 0.5),
            scheme.secondary.withValues(alpha: 0.25),
            scheme.tertiary.withValues(alpha: 0.18),
          ],
        ),
      ),
      child: Center(
        child: Text(
          profile.name.isNotEmpty
              ? profile.name.substring(0, 1).toUpperCase()
              : '?',
          style: AppTextStyles.display(color: AppColors.white).copyWith(
            fontSize: 120,
            shadows: <Shadow>[
              Shadow(
                color: scheme.primary.withValues(alpha: 0.8),
                blurRadius: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Nameplate extends StatelessWidget {
  const _Nameplate({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Flexible(
          child: Text(
            profile.name,
            style: AppTextStyles.display(color: AppColors.white).copyWith(
              shadows: <Shadow>[
                Shadow(
                  color: scheme.primary.withValues(alpha: 0.7),
                  blurRadius: 18,
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${profile.age}',
          style: AppTextStyles.headline(
            color: AppColors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.4),
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.circle, size: 8, color: AppColors.success),
          const SizedBox(width: AppSpacing.xs),
          Text('онлайн', style: AppTextStyles.caption(color: AppColors.white)),
        ],
      ),
    );
  }
}

/// Круговой индикатор совместимости (CustomPainter).
class _CompatibilityRing extends StatelessWidget {
  const _CompatibilityRing({required this.compatibility, required this.color});

  final int compatibility;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.black.withValues(alpha: 0.35),
        boxShadow: <BoxShadow>[
          BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 18),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: const Size.square(64),
            painter: _CompatibilityRingPainter(
              value: compatibility / 100,
              color: color,
              trackColor: color.withValues(alpha: 0.18),
            ),
          ),
          Text(
            '$compatibility%',
            style: AppTextStyles.label(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _CompatibilityRingPainter extends CustomPainter {
  _CompatibilityRingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
  });

  static const double _strokeWidth = 6;

  final double value;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius =
        math.min(size.width, size.height) / 2 - _strokeWidth / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    final Paint foreground = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, track);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * value.clamp(0.0, 1.0),
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _CompatibilityRingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}

class _Interests extends StatelessWidget {
  const _Interests({required this.interests, required this.color});

  final List<Interest> interests;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final Interest interest in interests.take(6))
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.pillAll,
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Text(
              interest.emoji == null
                  ? interest.name
                  : '${interest.emoji} ${interest.name}',
              style: AppTextStyles.caption(color: AppColors.textPrimary),
            ),
          ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.isBusy, this.onLike, this.onPass});

  final bool isBusy;
  final VoidCallback? onLike;
  final VoidCallback? onPass;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _ActionButton(
          icon: Icons.close_rounded,
          label: 'Пропустить',
          color: AppColors.error,
          onTap: isBusy ? null : onPass,
        ),
        _ActionButton(
          icon: Icons.favorite_rounded,
          label: 'Нравится',
          color: primary,
          filled: true,
          onTap: isBusy ? null : onLike,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.filled = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final Color onPrimary = Theme.of(context).colorScheme.onPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GlowContainer(
            color: color,
            glowRadius: enabled ? 22 : 0,
            glowOpacity: enabled ? 0.55 : 0,
            borderColor: color,
            background: filled ? color : color.withValues(alpha: 0.08),
            borderRadius: AppRadius.pillAll,
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            child: Icon(
              icon,
              size: 32,
              color: filled
                  ? onPrimary
                  : (enabled ? color : AppColors.textMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.label(
              color: enabled ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
