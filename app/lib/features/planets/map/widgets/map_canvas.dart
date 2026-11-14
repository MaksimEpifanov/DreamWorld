import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/index.dart';
import '../../../../data/models/map_spot.dart';
import '../../../../data/models/planet.dart';

class MapCanvas extends StatelessWidget {
  const MapCanvas({
    super.key,
    required this.planet,
    required this.spots,
    required this.selectedId,
    required this.onSpotTap,
    required this.onMapTap,
  });

  final Planet planet;
  final List<MapSpot> spots;
  final String? selectedId;
  final ValueChanged<MapSpot> onSpotTap;
  final ValueChanged<LatLng> onMapTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.card,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(30, 0),
          initialZoom: 2.2,
          minZoom: 2,
          maxZoom: 18,
          onTap: (TapPosition tapPosition, LatLng point) => onMapTap(point),
        ),
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.dreemworld.app.dreem_world',
            maxNativeZoom: 19,
            keepBuffer: 2,
          ),
          MarkerLayer(
            markers: <Marker>[
              for (final MapSpot spot in spots)
                Marker(
                  point: LatLng(spot.latitude ?? 0, spot.longitude ?? 0),
                  width: spot.id == selectedId ? 100 : 48,
                  height: spot.id == selectedId ? 82 : 48,
                  alignment: Alignment.topCenter,
                  child: _MapPin(
                    spot: spot,
                    planet: planet,
                    selected: spot.id == selectedId,
                    onTap: () => onSpotTap(spot),
                  ),
                ),
            ],
          ),
          RichAttributionWidget(
            alignment: AttributionAlignment.bottomRight,
            attributions: <SourceAttribution>[
              TextSourceAttribution(
                '© OpenStreetMap contributors',
                onTap: () => launchUrl(
                  Uri.parse('https://www.openstreetmap.org/copyright'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.spot,
    required this.planet,
    required this.selected,
    required this.onTap,
  });

  final MapSpot spot;
  final Planet planet;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = spot.color ?? planet.accent;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: selected ? 48 : 40,
            height: selected ? 48 : 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface.withValues(alpha: 0.96),
              border: Border.all(color: color, width: selected ? 2.5 : 1.5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: color.withValues(alpha: selected ? 0.7 : 0.4),
                  blurRadius: selected ? 22 : 12,
                  spreadRadius: selected ? 1 : -2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              spot.emoji,
              style: TextStyle(fontSize: selected ? 22 : 18),
            ),
          ),
          if (selected)
            Container(
              constraints: const BoxConstraints(maxWidth: 96),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.94),
                borderRadius: AppRadius.pillAll,
              ),
              child: Text(
                spot.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label(color: AppColors.textPrimary),
              ),
            ),
        ],
      ),
    );
  }
}
