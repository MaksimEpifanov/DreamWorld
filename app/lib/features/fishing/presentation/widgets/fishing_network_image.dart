import 'package:flutter/material.dart';

import 'fishing_mock_data.dart';

class FishingNetworkImage extends StatelessWidget {
  const FishingNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.icon = Icons.phishing_outlined,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  final String url;
  final BoxFit fit;
  final IconData icon;
  final double? width;
  final double? height;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      filterQuality: FilterQuality.medium,
      loadingBuilder:
          (BuildContext context, Widget child, ImageChunkEvent? progress) {
            if (progress == null) return child;
            return _fallback();
          },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return _fallback();
          },
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            FishingMockData.accent.withValues(alpha: 0.55),
            FishingMockData.cyan.withValues(alpha: 0.25),
            const Color(0xFF0B1730),
          ],
        ),
      ),
      child: Icon(icon, color: Colors.white.withValues(alpha: 0.65), size: 28),
    );
  }
}
