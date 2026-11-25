import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import 'voice_player.dart';

class VoiceMessagePlayer extends StatefulWidget {
  const VoiceMessagePlayer({
    super.key,
    required this.audioUrl,
    required this.durationMs,
    required this.isMine,
  });

  final String audioUrl;
  final int durationMs;
  final bool isMine;

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  late final VoicePlayer _player;
  StreamSubscription<void>? _sub;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _player = createVoicePlayer();
    _sub = _player.changes.listen((_) {
      if (mounted) setState(() {});
    });
    _init();
  }

  Future<void> _init() async {
    await _player.setSource(widget.audioUrl);
    if (mounted) setState(() => _ready = true);
  }

  @override
  void didUpdateWidget(covariant VoiceMessagePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _ready = false;
      _player.setSource(widget.audioUrl).then((_) {
        if (mounted) setState(() => _ready = true);
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _fmt(int ms) {
    final int total = (ms / 1000).floor();
    final int m = total ~/ 60;
    final int s = total % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color fg = widget.isMine ? scheme.onPrimary : AppColors.white;
    final int totalMs = _player.durationMs > 0
        ? _player.durationMs
        : widget.durationMs;
    final int posMs = _player.positionMs.clamp(
      0,
      totalMs > 0 ? totalMs : 1 << 30,
    );
    final double progress = totalMs > 0
        ? (posMs / totalMs).clamp(0.0, 1.0)
        : 0.0;

    return SizedBox(
      width: 220,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: !_ready
                ? null
                : () async {
                    if (_player.isPlaying) {
                      await _player.pause();
                    } else {
                      await _player.play();
                    }
                  },
            icon: Icon(
              _player.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: fg,
            ),
            iconSize: 28,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 10,
                    ),
                    activeTrackColor: fg,
                    inactiveTrackColor: fg.withValues(alpha: 0.3),
                    thumbColor: fg,
                  ),
                  child: Slider(
                    value: progress,
                    onChanged: totalMs <= 0
                        ? null
                        : (double v) => _player.seekMs((v * totalMs).round()),
                  ),
                ),
                Text(
                  '${_fmt(posMs)} / ${_fmt(totalMs)}',
                  style: AppTextStyles.caption(
                    color: fg.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
