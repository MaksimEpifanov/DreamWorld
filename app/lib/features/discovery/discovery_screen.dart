import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/models/index.dart';
import '../../data/providers/app_providers.dart';
import '../../data/services/scoring_service.dart';
import '../safety/widgets/report_sheet.dart';
import 'widgets/user_card.dart';

/// Экран подбора: карточки кандидатов и эмуляция взаимного мэтча.
class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  int _index = 0;
  bool _isBusy = false;

  void _advance() {
    setState(() {
      _index++;
      _isBusy = false;
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _isBusy = false;
    });
  }

  Future<void> _like(Profile profile) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    final Match match = await ref
        .read(matchRepositoryProvider)
        .likeProfile(profile.id);
    if (!mounted) return;

    final bool mutual = match.isActive;
    setState(() {
      _isBusy = false;
      _index++;
    });

    if (mutual) {
      context.push('/match?userId=${Uri.encodeComponent(profile.id)}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Симпатия отправлена. ${profile.name} ответит позже.'),
        ),
      );
    }
  }

  Future<void> _pass(Profile profile) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    await ref.read(matchRepositoryProvider).passProfile(profile.id);
    if (!mounted) return;
    _advance();
  }

  Future<void> _report(Profile profile) async {
    final bool sent = await showReportSheet(
      context,
      ref,
      targetId: profile.id,
      targetName: profile.name,
      target: ReportTarget.user,
    );
    if (sent && mounted) {
      setState(() => _index++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ScoredProfile>> profilesAsync = ref.watch(
      rankedDiscoveryProfilesProvider,
    );

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Dream World',
        leading: BackButton(onPressed: () => context.go('/main')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: profilesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) => const _Message(
              icon: Icons.error_outline_rounded,
              text: 'Не удалось загрузить анкеты',
            ),
            data: (List<ScoredProfile> profiles) {
              if (profiles.isEmpty) {
                return const _Message(
                  icon: Icons.explore_off_outlined,
                  text: 'Пока нет анкет для подбора',
                );
              }
              if (_index >= profiles.length) {
                return _Message(
                  icon: Icons.done_all_rounded,
                  text: 'Анкеты закончились',
                  actionLabel: 'Начать заново',
                  onAction: _restart,
                );
              }

              final ScoredProfile candidate = profiles[_index];
              final Profile profile = candidate.profile;
              final int compatibility = candidate.score;

              return Column(
                children: <Widget>[
                  _ProgressHeader(
                    index: _index,
                    total: profiles.length,
                    isBusy: _isBusy,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: AppSpacing.page,
                      child: UserCard(
                        key: ValueKey<String>(profile.id),
                        profile: profile,
                        compatibility: compatibility,
                        relationshipStatus: ref.watch(
                          relationshipStatusProvider(profile.id),
                        ),
                        isBusy: _isBusy,
                        onLike: () => _like(profile),
                        onPass: () => _pass(profile),
                        onReport: () => _report(profile),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.index,
    required this.total,
    required this.isBusy,
  });

  final int index;
  final int total;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double progress = total == 0 ? 0 : (index + 1) / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.auto_awesome, size: 16, color: scheme.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Анкета ${index + 1} из $total',
                style: AppTextStyles.caption(),
              ),
              const Spacer(),
              if (isBusy)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (BuildContext context, double value, Widget? child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GlowContainer(
              color: primary,
              glowRadius: 24,
              glowOpacity: 0.45,
              borderColor: primary,
              background: AppColors.surface,
              borderRadius: AppRadius.pillAll,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Icon(icon, size: 40, color: primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              text,
              style: AppTextStyles.title(),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              NeonButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
        );
  }
}
