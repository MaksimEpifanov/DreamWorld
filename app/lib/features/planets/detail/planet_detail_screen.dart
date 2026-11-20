import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/planet_genre_visuals.dart';
import '../../../core/constants/planet_scene_theme.dart';
import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/profile.dart';
import '../../../data/models/planet.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/planet_providers.dart';
import '../events/widgets/planet_events_section.dart';
import '../news/widgets/news_section.dart';
import 'widgets/cinema_planet_layout.dart';
import 'widgets/planet_hero_orb.dart';
import 'widgets/planet_interest_checklist.dart';
import 'widgets/planet_member_tile.dart';
import 'widgets/planet_scene.dart';
import 'widgets/planet_stat_chip.dart';

/// «Внутренний мир» планеты: оформление под её увлечение и участники.
class PlanetDetailScreen extends ConsumerWidget {
  const PlanetDetailScreen({super.key, required this.planetId});

  final String planetId;

  Future<void> _join(BuildContext context, WidgetRef ref, Planet planet) async {
    try {
      await ref.read(planetMembershipControllerProvider).toggle(planet.id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Не удалось вступить. Попробуйте ещё раз.'),
          ),
        );
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text('Вы присоединились к «${planet.displayName}»')),
      );
  }

  Future<void> _leave(
    BuildContext context,
    WidgetRef ref,
    Planet planet,
  ) async {
    try {
      await ref.read(planetMembershipControllerProvider).toggle(planet.id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Не удалось выйти. Попробуйте ещё раз.'),
          ),
        );
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text('Вы покинули «${planet.displayName}»')),
      );
  }

  Widget _buildLegacyList(
    BuildContext context,
    WidgetRef ref,
    Planet planet,
    AsyncValue<List<Profile>> members,
    int memberCount,
    bool joined,
  ) {
    return ListView(
      padding: AppSpacing.page,
      children: <Widget>[
        _PlanetHeader(planet: planet, memberCount: memberCount),
        const SizedBox(height: AppSpacing.lg),
        if (joined) ...<Widget>[
          NeonButton(
            label: 'Вы уже присоединились',
            icon: Icons.check_circle_outline_rounded,
            expanded: true,
            color: planet.accent,
            onPressed: null,
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: () => _leave(context, ref, planet),
            child: const Text('Покинуть планету'),
          ),
        ] else
          NeonButton(
            label: 'Присоединиться',
            icon: Icons.rocket_launch_outlined,
            expanded: true,
            color: planet.primary,
            onPressed: () => _join(context, ref, planet),
          ),
        const SizedBox(height: AppSpacing.sm),
        NeonButton(
          label: 'Смотреть всех в подборе',
          icon: Icons.explore_outlined,
          variant: NeonButtonVariant.outlined,
          expanded: true,
          color: planet.secondary,
          onPressed: () => context.go('/discovery'),
        ),
        const SizedBox(height: AppSpacing.lg),
        PlanetInterestChecklist(planet: planet),
        const SizedBox(height: AppSpacing.lg),
        NeonButton(
          label: 'Карта планеты',
          icon: Icons.map_outlined,
          variant: NeonButtonVariant.outlined,
          expanded: true,
          color: planet.accent,
          onPressed: () => context.go('/main/planet/${planet.id}/map'),
        ),
        const SizedBox(height: AppSpacing.sm),
        NeonButton(
          label: 'Чат сообщества',
          icon: Icons.forum_outlined,
          variant: NeonButtonVariant.outlined,
          expanded: true,
          color: planet.secondary,
          onPressed: () => context.go('/main/planet/${planet.id}/chat'),
        ),
        const SizedBox(height: AppSpacing.lg),
        PlanetEventsSection(planet: planet),
        const SizedBox(height: AppSpacing.lg),
        NewsSection(planet: planet),
        const SizedBox(height: AppSpacing.lg),
        Text('Участники планеты', style: AppTextStyles.title()),
        const SizedBox(height: AppSpacing.sm),
        members.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (Object error, StackTrace stackTrace) => Text(
            'Не удалось загрузить участников',
            style: AppTextStyles.body(color: AppColors.textMuted),
          ),
          data: (List<Profile> list) => list.isEmpty
              ? Text(
                  'Пока никто не вступил. Станьте первым участником — '
                  'и другие смогут найти вас здесь.',
                  style: AppTextStyles.body(color: AppColors.textSecondary),
                )
              : Column(
                  children: <Widget>[
                    for (final Profile profile in list)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: PlanetMemberTile(profile: profile),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Planet? planet = ref.watch(planetByIdProvider(planetId));

    if (planet == null) {
      return Scaffold(
        appBar: NeonAppBar(
          title: 'Планета',
          leading: BackButton(onPressed: () => context.go('/main')),
        ),
        body: const Center(child: Text('Планета не найдена')),
      );
    }

    final AsyncValue<List<Profile>> members = ref.watch(
      planetMembersProvider(planetId),
    );
    final int memberCount = ref.watch(planetMemberCountProvider(planetId));
    final bool joined =
        ref
            .watch(currentProfileProvider)
            .valueOrNull
            ?.joinedPlanetIds
            .contains(planetId) ??
        false;

    final List<PlanetGenreVisual>? visuals =
        planetGenreVisualsByScene[planet.scene];
    final String? coverPath = planetCoverByPlanetId[planet.id];
    final bool useThemedLayout =
        visuals != null && visuals.isNotEmpty && coverPath != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: NeonAppBar(
        title: planet.displayName,
        leading: BackButton(onPressed: () => context.go('/main')),
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: PlanetSceneBackground(
              scene: planet.scene,
              primary: planet.primary,
              secondary: planet.secondary,
              accent: planet.accent,
            ),
          ),
          SafeArea(
            child: useThemedLayout
                ? CinemaPlanetLayout(
                    planet: planet,
                    theme: themeForScene(planet.scene),
                    coverPath: coverPath,
                    memberCount: memberCount,
                    joined: joined,
                    onJoin: () => _join(context, ref, planet),
                    onLeave: () => _leave(context, ref, planet),
                  )
                : ResponsiveContent(
                    child: _buildLegacyList(
                      context,
                      ref,
                      planet,
                      members,
                      memberCount,
                      joined,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Шапка планеты: орбитальный неоновый шар, название и чипы-статистика.
class _PlanetHeader extends StatelessWidget {
  const _PlanetHeader({required this.planet, required this.memberCount});

  final Planet planet;
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: AppSpacing.lg),
        PlanetHeroOrb(planet: planet),
        const SizedBox(height: AppSpacing.lg),
        Text(
              planet.displayName,
              style: AppTextStyles.display(),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(duration: 500.ms, delay: 100.ms)
            .slideY(
              begin: 0.3,
              end: 0,
              duration: 500.ms,
              delay: 100.ms,
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          planet.tagline,
          style: AppTextStyles.body(color: planet.accent),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
        const SizedBox(height: AppSpacing.sm),
        Text(
          planet.description,
          style: AppTextStyles.body(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 500.ms, delay: 280.ms),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: <Widget>[
            PlanetStatChip(
              icon: Icons.people_alt_outlined,
              label: '$memberCount участников',
              color: planet.accent,
            ),
            PlanetStatChip(
              icon: Icons.local_fire_department_outlined,
              label: planet.keywords.take(2).join(' · '),
              color: planet.secondary,
              outlined: true,
            ),
          ],
        ).animate().fadeIn(duration: 500.ms, delay: 360.ms),
      ],
    );
  }
}
