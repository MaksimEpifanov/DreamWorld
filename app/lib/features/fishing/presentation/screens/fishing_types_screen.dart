import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../widgets/fishing_glass_panel.dart';
import '../widgets/fishing_mock_data.dart';
import '../widgets/fishing_navigation_rail.dart';
import '../widgets/fishing_types_data.dart';

class FishingTypesScreen extends StatefulWidget {
  const FishingTypesScreen({super.key});

  @override
  State<FishingTypesScreen> createState() => _FishingTypesScreenState();
}

class _FishingTypesScreenState extends State<FishingTypesScreen> {
  String _category = FishingTypesData.categories.first;
  String? _expandedTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: CosmicBackground(
              tint: FishingMockData.accent,
              tintOpacity: 0.08,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double width = constraints.maxWidth;
                final bool compactRail = width < 900;
                final double maxHeight = constraints.hasBoundedHeight
                    ? constraints.maxHeight
                    : 900;
                final double railHeight = (maxHeight - 32)
                    .clamp(280.0, 600.0)
                    .toDouble();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                      child: FishingNavigationRail(
                        activeLabel: 'Виды ловли',
                        compact: compactRail,
                        height: railHeight,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1100),
                            child: _content(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double contentWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 800;
        final bool twoColumns = contentWidth >= 700;
        final double cardWidth = twoColumns ? (contentWidth - 12) / 2 : contentWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _header(),
            const SizedBox(height: 16),
            _filters(),
            const SizedBox(height: 22),
            _sectionTitle(
              icon: Icons.explore_outlined,
              title: 'Все виды ловли',
              subtitle:
                  '${_visibleTypes.length} способов — откройте карточку для деталей',
            ),
            const SizedBox(height: 12),
            _typeCards(cardWidth),
            const SizedBox(height: 24),
            _sectionTitle(
              icon: Icons.school_outlined,
              title: 'Советы новичкам',
              subtitle: 'С чего начать и как не потерять снасть',
            ),
            const SizedBox(height: 12),
            _tipCards(cardWidth),
            const SizedBox(height: 24),
            _sectionTitle(
              icon: Icons.error_outline,
              title: 'Главные ошибки рыбака',
              subtitle: 'Частые промахи и как их исправить',
            ),
            const SizedBox(height: 12),
            _mistakeCards(cardWidth),
            const SizedBox(height: 24),
            _sectionTitle(
              icon: Icons.shield_outlined,
              title: 'Безопасность и правила',
              subtitle: 'Вода, лёд, снасть и закон',
            ),
            const SizedBox(height: 12),
            _safetyCards(),
            const SizedBox(height: 24),
            _sourcesPanel(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  List<FishingTypeInfo> get _visibleTypes {
    if (_category == FishingTypesData.categories.first) {
      return FishingTypesData.types;
    }
    return FishingTypesData.types
        .where((FishingTypeInfo type) => type.category == _category)
        .toList();
  }

  Widget _header() {
    return FishingGlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            key: const ValueKey<String>('fishing-types-back'),
            onTap: () => context.go('/main/planet/p_fishing'),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: FishingMockData.cyan,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Назад к рыбалке',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(color: FishingMockData.cyan),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: <Color>[FishingMockData.accent, FishingMockData.cyan],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: FishingMockData.accent.withValues(alpha: 0.4),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.explore_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Виды ловли',
                      style: AppTextStyles.headline(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Спиннинг, фидер, нахлыст и другие способы — '
                      'снасти, советы и главные ошибки',
                      style: AppTextStyles.body(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final String category in FishingTypesData.categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                key: ValueKey<String>('fishing-type-filter-$category'),
                onTap: () => setState(() {
                  _category = category;
                  _expandedTitle = null;
                }),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: category == _category
                        ? FishingMockData.accent.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: category == _category
                          ? FishingMockData.cyan
                          : Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    category,
                    style: AppTextStyles.label(
                      color: category == _category
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(icon, color: FishingMockData.cyan, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AppTextStyles.title(color: Colors.white)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _typeCards(double cardWidth) {
    final List<FishingTypeInfo> types = _visibleTypes;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final FishingTypeInfo type in types)
          SizedBox(width: cardWidth, child: _typeCard(type)),
      ],
    );
  }

  Widget _typeCard(FishingTypeInfo type) {
    final bool expanded = _expandedTitle == type.title;
    final Color color = _categoryColor(type.category);

    return FishingGlassPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            key: ValueKey<String>('fishing-type-card-${type.title}'),
            onTap: () => setState(() {
              _expandedTitle = expanded ? null : type.title;
            }),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: <Color>[
                          color.withValues(alpha: 0.55),
                          color.withValues(alpha: 0.15),
                        ],
                      ),
                      border: Border.all(color: color.withValues(alpha: 0.6)),
                    ),
                    child: Icon(type.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          type.title,
                          style: AppTextStyles.bodyBold(color: Colors.white),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${type.category} · ${type.short}',
                          style: AppTextStyles.caption(),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: FishingMockData.cyan,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              key: ValueKey<String>('fishing-type-details-${type.title}'),
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Divider(color: Colors.white.withValues(alpha: 0.1)),
                  const SizedBox(height: 8),
                  Text(
                    type.description,
                    style: AppTextStyles.body(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  _detailLine('Снасть', type.gear, color),
                  const SizedBox(height: 8),
                  _detailLine('Приманки', type.baits, color),
                  const SizedBox(height: 10),
                  Text(
                    'Где ловить: ${type.place}',
                    style: AppTextStyles.caption(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: FishingMockData.cyan.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: FishingMockData.cyan.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(
                          Icons.tips_and_updates_outlined,
                          color: FishingMockData.cyan,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            type.tip,
                            style: AppTextStyles.caption(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailLine(String label, List<String> values, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTextStyles.label(color: color),
        ),
        const SizedBox(height: 4),
        Text(
          values.join(' · '),
          style: AppTextStyles.caption(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _tipCards(double cardWidth) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final FishingTip tip in FishingTypesData.beginnerTips)
          SizedBox(
            width: cardWidth,
            child: FishingGlassPanel(
              key: ValueKey<String>('fishing-beginner-tip-${tip.title}'),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(tip.icon, color: FishingMockData.cyan, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          tip.title,
                          style: AppTextStyles.bodyBold(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip.body,
                          style: AppTextStyles.caption(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _mistakeCards(double cardWidth) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final FishingMistake mistake in FishingTypesData.commonMistakes)
          SizedBox(
            width: cardWidth,
            child: FishingGlassPanel(
              key: ValueKey<String>('fishing-mistake-${mistake.title}'),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(mistake.icon, color: Colors.orangeAccent, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          mistake.title,
                          style: AppTextStyles.bodyBold(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(mistake.body, style: AppTextStyles.caption()),
                        const SizedBox(height: 6),
                        Text(
                          'Как избежать: ${mistake.fix}',
                          style: AppTextStyles.caption(
                            color: FishingMockData.cyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _safetyCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final FishingSafetyRule rule in FishingTypesData.safetyRules)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FishingGlassPanel(
              key: ValueKey<String>('fishing-safety-${rule.title}'),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(rule.icon, color: FishingMockData.accent, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          rule.title,
                          style: AppTextStyles.bodyBold(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(rule.body, style: AppTextStyles.caption()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _sourcesPanel() {
    return FishingGlassPanel(
      key: const ValueKey<String>('fishing-types-sources'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.menu_book_outlined,
                color: FishingMockData.cyan,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Источники информации',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final FishingSource source in FishingTypesData.sources)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    source.title,
                    style: AppTextStyles.caption(color: Colors.white),
                  ),
                  Text(
                    source.url,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 11,
                      color: FishingMockData.cyan,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            'Советы и ошибки собраны по открытым материалам о рыбалке.',
            style: AppTextStyles.caption(),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Хищная':
        return FishingMockData.accent;
      case 'Мирная':
        return FishingMockData.cyan;
      case 'Зимняя':
        return const Color(0xFF7DD3FC);
      case 'Морская':
        return const Color(0xFF4FD1C5);
      case 'Нахлыст':
        return const Color(0xFFF6AD55);
      default:
        return FishingMockData.accent;
    }
  }
}
