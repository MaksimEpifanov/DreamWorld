import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/conversation.dart';
import '../../../../data/models/profile.dart';
import '../../../../data/providers/app_providers.dart';

class PlanetMemberTile extends ConsumerWidget {
  const PlanetMemberTile({super.key, required this.profile, this.compact = false});

  final Profile profile;
  final bool compact;

  Future<void> _openChat(BuildContext context, WidgetRef ref) async {
    try {
      final Conversation conversation = await ref
          .read(chatRepositoryProvider)
          .getOrCreateConversation(profile.id);
      if (context.mounted) context.push('/chat/${conversation.id}');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Не удалось открыть чат. Попробуйте ещё раз.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int compatibility =
        ref.watch(compatibilityProvider(profile)).asData?.value ?? 0;
    final bool isSelf = profile.id == ref.watch(currentUserIdProvider);

    final double spaceMd = compact ? CompactSpace.sm : AppSpacing.md;
    final double spaceSm = compact ? CompactSpace.xs : AppSpacing.sm;
    final double spaceXs = compact ? CompactSpace.xxs : AppSpacing.xs;
    final double spaceXxs = compact ? 1 : AppSpacing.xxs;

    return GlassCard(
      blur: 0,
      compact: compact,
      padding: EdgeInsets.all(compact ? CompactSpace.xs : AppSpacing.sm),
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: isSelf ? null : () => _openChat(context, ref),
        child: Row(
          children: <Widget>[
            AuraAvatar(
              photoUrl: profile.photoUrl,
              size: compact ? 26 : 52,
              fallbackText: profile.name,
            ),
            SizedBox(width: spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          profile.name,
                          style: compact
                              ? CompactText.bodyBold()
                              : AppTextStyles.bodyBold(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelf) ...<Widget>[
                        SizedBox(width: spaceXs),
                        Text(
                          '(вы)',
                          style: compact
                              ? CompactText.caption()
                              : AppTextStyles.caption(),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: spaceXxs),
                  Text(
                    <String>[
                      if (profile.city != null) profile.city!,
                      if (profile.interestNames.isNotEmpty)
                        profile.interestNames.take(2).join(', '),
                    ].join(' • '),
                    style:
                        compact ? CompactText.caption() : AppTextStyles.caption(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: spaceSm),
            if (!isSelf)
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: compact ? 12 : 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            SizedBox(width: spaceSm),
            CompatibilityRing(
              percent: compatibility / 100,
              size: compact ? 24 : 48,
              strokeWidth: compact ? 3 : 5,
            ),
          ],
        ),
      ),
    );
  }
}
