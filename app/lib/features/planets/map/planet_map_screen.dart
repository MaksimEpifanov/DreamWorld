import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/map_spot.dart';
import '../../../data/models/planet.dart';
import '../../../data/providers/planet_providers.dart';
import 'widgets/map_canvas.dart';
import 'widgets/spot_sheet.dart';

/// Карта «внутреннего мира» планеты: отметки мест с тегами, фото и
/// комментариями.
class PlanetMapScreen extends ConsumerStatefulWidget {
  const PlanetMapScreen({super.key, required this.planetId});

  final String planetId;

  @override
  ConsumerState<PlanetMapScreen> createState() => _PlanetMapScreenState();
}

class _PlanetMapScreenState extends ConsumerState<PlanetMapScreen> {
  String? _selectedId;
  bool _isAddingSpot = false;

  @override
  Widget build(BuildContext context) {
    final Planet? planet = ref.watch(planetByIdProvider(widget.planetId));

    if (planet == null) {
      return Scaffold(
        appBar: NeonAppBar(
          title: 'Карта',
          leading: BackButton(
            onPressed: () => context.go('/main/planet/${widget.planetId}'),
          ),
        ),
        body: const Center(child: Text('Планета не найдена')),
      );
    }

    final List<MapSpot> spots = ref.watch(
      planetMapSpotsProvider(widget.planetId),
    );

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Карта · ${planet.name}',
        leading: BackButton(
          onPressed: () => context.go('/main/planet/${planet.id}'),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _MapIntro(planet: planet, count: spots.length),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: MapCanvas(
                    planet: planet,
                    spots: spots,
                    selectedId: _selectedId,
                    onMapTap: (LatLng point) {
                      if (_isAddingSpot) _createSpot(point, planet);
                    },
                    onSpotTap: (MapSpot spot) {
                      setState(() => _selectedId = spot.id);
                      showSpotSheet(
                        context,
                        spot: spot,
                        planet: planet,
                        onCommentAdded: (MapComment comment) => ref
                            .read(
                              planetMapSpotsProvider(widget.planetId).notifier,
                            )
                            .addComment(spot.id, comment),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        _isAddingSpot
                            ? 'Нажмите на карте, чтобы выбрать место.'
                            : 'Нажмите на отметку, чтобы посмотреть детали.',
                        style: AppTextStyles.caption(),
                      ),
                    ),
                    NeonButton(
                      label: _isAddingSpot ? 'Отмена' : 'Добавить место',
                      icon: _isAddingSpot
                          ? Icons.close_rounded
                          : Icons.add_location_alt_outlined,
                      color: planet.secondary,
                      onPressed: () {
                        setState(() => _isAddingSpot = !_isAddingSpot);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createSpot(LatLng point, Planet planet) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Новая отметка'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: titleController,
              autofocus: true,
              maxLength: 48,
              decoration: const InputDecoration(labelText: 'Название места'),
            ),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              maxLength: 240,
              decoration: const InputDecoration(
                labelText: 'Комментарий или впечатление',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              titleController.text.trim().isNotEmpty,
            ),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
    final String title = titleController.text.trim();
    final String description = descriptionController.text.trim();
    titleController.dispose();
    descriptionController.dispose();
    if (confirmed != true || title.isEmpty || !mounted) return;

    final List<MapComment> comments = description.isEmpty
        ? const <MapComment>[]
        : <MapComment>[MapComment(authorName: 'Вы', text: description)];
    final MapSpot spot = MapSpot(
      id: const Uuid().v4(),
      title: title,
      description: description.isEmpty
          ? 'Место на карте планеты.'
          : description,
      authorName: 'Вы',
      emoji: '📍',
      tags: planet.keywords.take(2).toList(growable: false),
      likes: 0,
      x: (point.longitude + 180) / 360,
      y: (90 - point.latitude) / 180,
      latitude: point.latitude,
      longitude: point.longitude,
      color: planet.accent,
      comments: comments,
    );
    ref.read(planetMapSpotsProvider(widget.planetId).notifier).add(spot);
    setState(() {
      _selectedId = spot.id;
      _isAddingSpot = false;
    });
  }
}

/// Короткая шапка карты: название, число отметок и теги интересов планеты.
class _MapIntro extends StatelessWidget {
  const _MapIntro({required this.planet, required this.count});

  final Planet planet;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(planet.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                '$count отметок участников',
                style: AppTextStyles.bodyBold(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            for (final String tag in planet.keywords)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: planet.accent.withValues(alpha: 0.12),
                  borderRadius: AppRadius.pillAll,
                  border: Border.all(
                    color: planet.accent.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: AppTextStyles.label(color: planet.accent),
                ),
              ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.1);
  }
}
