import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/models/index.dart';
import '../../data/providers/app_providers.dart';
import 'contacts_controller.dart';

/// Экран сканирования QR-кода.
///
/// Настоящая камера подключится позже; сейчас сканирование эмулируется —
/// «распознаётся» первый участник подбора, которого ещё нет в контактах.
class ScanQrScreen extends ConsumerStatefulWidget {
  const ScanQrScreen({super.key});

  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  bool _scanning = false;

  Future<void> _scan() async {
    if (_scanning) return;
    setState(() => _scanning = true);

    final List<String> existing = ref.read(contactsProvider);
    final List<Profile> profiles =
        ref.read(discoveryProfilesProvider).asData?.value ?? const <Profile>[];
    final Profile? found = profiles
        .where((Profile p) => !existing.contains(p.id))
        .cast<Profile?>()
        .firstWhere((Profile? p) => true, orElse: () => null);

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _scanning = false);

    if (found == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Все знакомые уже в контактах')),
      );
      return;
    }

    final ColorScheme scheme = Theme.of(context).colorScheme;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Контакт найден'),
        content: Row(
          children: <Widget>[
            AuraAvatar(
              photoUrl: found.photoUrl,
              size: 52,
              fallbackText: found.name,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(found.name, style: AppTextStyles.bodyBold()),
                  if ((found.city ?? '').isNotEmpty)
                    Text(found.city!, style: AppTextStyles.caption()),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.primary),
            onPressed: () {
              ref.read(contactsProvider.notifier).add(found.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${found.name} добавлен(а) в контакты')),
              );
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Сканирование QR',
        leading: BackButton(onPressed: () => context.go('/contacts')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: Padding(
            padding: AppSpacing.page,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.xlAll,
                            border: Border.all(
                              color: scheme.primary.withValues(alpha: 0.6),
                              width: 2,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 140,
                          color: scheme.primary.withValues(alpha: 0.25),
                        ),
                        if (_scanning)
                          Positioned.fill(
                            child:
                                Container(
                                      decoration: BoxDecoration(
                                        borderRadius: AppRadius.xlAll,
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: <Color>[
                                            scheme.primary.withValues(alpha: 0),
                                            scheme.primary.withValues(
                                              alpha: 0.35,
                                            ),
                                            scheme.primary.withValues(alpha: 0),
                                          ],
                                        ),
                                      ),
                                    )
                                    .animate(
                                      onPlay: (AnimationController c) =>
                                          c.repeat(),
                                    )
                                    .slideY(
                                      begin: -0.6,
                                      end: 0.6,
                                      duration: 1200.ms,
                                    ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Наведите камеру на QR-код друга',
                    style: AppTextStyles.title(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Сканирование пока работает в демо-режиме.',
                    style: AppTextStyles.caption(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  NeonButton(
                    label: _scanning ? 'Сканируем…' : 'Сканировать',
                    icon: Icons.qr_code_scanner_rounded,
                    expanded: true,
                    isLoading: _scanning,
                    onPressed: _scan,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
