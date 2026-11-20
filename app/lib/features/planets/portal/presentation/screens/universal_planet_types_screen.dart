import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/index.dart';
import '../../../../../core/widgets/index.dart';
import '../../data/portal_catalog.dart';
import '../../data/universal_portal_dataset.dart';
import '../widgets/portal_glass_panel.dart';
import '../widgets/portal_navigation_rail.dart';

class UniversalPlanetTypesScreen extends StatefulWidget {
  const UniversalPlanetTypesScreen({
    super.key,
    required this.planetId,
  });

  final String planetId;

  @override
  State<UniversalPlanetTypesScreen> createState() =>
      _UniversalPlanetTypesScreenState();
}

class _UniversalPlanetTypesScreenState
    extends State<UniversalPlanetTypesScreen> {
  PortalDataset? _dataset;
  String _category = 'Все';
  String? _expandedTitle;

  @override
  void initState() {
    super.initState();
    _dataset = PortalCatalog.dataset(widget.planetId);
    if (_dataset != null && _dataset!.categories.isNotEmpty) {
      _category = _dataset!.categories.first;
    }
  }

  @override
  void didUpdateWidget(UniversalPlanetTypesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.planetId != widget.planetId) {
      setState(() {
        _dataset = PortalCatalog.dataset(widget.planetId);
        _category = _dataset?.categories.first ?? 'Все';
        _expandedTitle = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: CosmicBackground(
              tint: PortalCatalog.accent,
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
                      child: PortalNavigationRail(
                        planetId: widget.planetId,
                        activeLabel: PortalCatalog.kindsLabel(widget.planetId),
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
    final PortalDataset? data = _dataset;
    if (data == null) {
      return PortalGlassPanel(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Данные для этой планеты готовятся.',
          style: AppTextStyles.body(color: AppColors.textSecondary),
        ),
      );
    }

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
            _header(data),
            const SizedBox(height: 16),
            _filters(data),
            const SizedBox(height: 22),
            _sectionTitle(
              icon: Icons.explore_outlined,
              title: data.kindsLabel,
              subtitle:
                  '${_visibleTypes(data).length} способов — откройте карточку для деталей',
            ),
            const SizedBox(height: 12),
            _typeCards(cardWidth, data),
            const SizedBox(height: 24),
            _sectionTitle(
              icon: Icons.school_outlined,
              title: 'Советы новичкам',
              subtitle: 'С чего начать и как ухаживать',
            ),
            const SizedBox(height: 12),
            _tipCards(cardWidth, data),
            const SizedBox(height: 24),
            _sectionTitle(
              icon: Icons.error_outline,
              title: 'Главные ошибки',
              subtitle: 'Частые промахи и как их исправить',
            ),
            const SizedBox(height: 12),
            _mistakeCards(cardWidth, data),
            const SizedBox(height: 24),
            _sectionTitle(
              icon: Icons.shield_outlined,
              title: 'Безопасность и правила',
              subtitle: 'Важное для участников сообщества',
            ),
            const SizedBox(height: 12),
            _safetyCards(data),
            const SizedBox(height: 24),
            _sourcesPanel(data),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  List<PortalTypeInfo> _visibleTypes(PortalDataset data) {
    if (_category == data.categories.first) return data.types;
    return data.types
        .where((PortalTypeInfo type) => type.category == _category)
        .toList();
  }

  Widget _header(PortalDataset data) {
    return PortalGlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            key: ValueKey<String>('portal-types-back-${widget.planetId}'),
            onTap: () => context.go('/main/planet/${widget.planetId}'),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: PortalCatalog.cyan,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Назад к ${PortalCatalog.title(widget.planetId)}',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(color: PortalCatalog.cyan),
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
                    colors: <Color>[
                      PortalCatalog.accent,
                      PortalCatalog.cyan,
                    ],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: PortalCatalog.accent.withValues(alpha: 0.4),
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
                      data.kindsLabel,
                      style: AppTextStyles.headline(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PortalCatalog.subtitle(widget.planetId),
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

  Widget _filters(PortalDataset data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final String category in data.categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                key: ValueKey<String>(
                  'portal-type-filter-${widget.planetId}-$category',
                ),
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
                        ? PortalCatalog.accent.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: category == _category
                          ? PortalCatalog.cyan
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
        Icon(icon, color: PortalCatalog.cyan, size: 20),
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

  Widget _typeCards(double cardWidth, PortalDataset data) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final PortalTypeInfo type in _visibleTypes(data))
          SizedBox(width: cardWidth, child: _typeCard(type)),
      ],
    );
  }

  Widget _typeCard(PortalTypeInfo type) {
    final bool expanded = _expandedTitle == type.title;
    final Color color = PortalCatalog.cyan;

    return PortalGlassPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            key: ValueKey<String>(
              'portal-type-card-${widget.planetId}-${type.title}',
            ),
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
                    color: PortalCatalog.cyan,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              key: ValueKey<String>(
                'portal-type-details-${widget.planetId}-${type.title}',
              ),
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
                  _detailLine('Что понадобится', type.gear, color),
                  const SizedBox(height: 8),
                  _detailLine('Что можно добавить', type.extras, color),
                  const SizedBox(height: 10),
                  Text(
                    'Где встречается: ${type.place}',
                    style: AppTextStyles.caption(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PortalCatalog.cyan.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: PortalCatalog.cyan.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(
                          Icons.tips_and_updates_outlined,
                          color: PortalCatalog.cyan,
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
        Text(label, style: AppTextStyles.label(color: color)),
        const SizedBox(height: 4),
        Text(
          values.join(' · '),
          style: AppTextStyles.caption(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _tipCards(double cardWidth, PortalDataset data) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final PortalTip tip in data.tips)
          SizedBox(
            width: cardWidth,
            child: PortalGlassPanel(
              key: ValueKey<String>(
                'portal-tip-${widget.planetId}-${tip.title}',
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(tip.icon, color: PortalCatalog.cyan, size: 22),
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
                        Text(tip.body, style: AppTextStyles.caption()),
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

  Widget _mistakeCards(double cardWidth, PortalDataset data) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final PortalMistake mistake in data.mistakes)
          SizedBox(
            width: cardWidth,
            child: PortalGlassPanel(
              key: ValueKey<String>(
                'portal-mistake-${widget.planetId}-${mistake.title}',
              ),
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
                          style: AppTextStyles.caption(color: PortalCatalog.cyan),
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

  Widget _safetyCards(PortalDataset data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final PortalSafetyRule rule in data.safety)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PortalGlassPanel(
              key: ValueKey<String>(
                'portal-safety-${widget.planetId}-${rule.title}',
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(rule.icon, color: PortalCatalog.accent, size: 22),
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

  Widget _sourcesPanel(PortalDataset data) {
    return PortalGlassPanel(
      key: ValueKey<String>('portal-types-sources-${widget.planetId}'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.menu_book_outlined,
                color: PortalCatalog.cyan,
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
          for (final PortalSource source in data.sources)
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
                      color: PortalCatalog.cyan,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            'Советы и ошибки собраны по открытым материалам.',
            style: AppTextStyles.caption(),
          ),
        ],
      ),
    );
  }
}
