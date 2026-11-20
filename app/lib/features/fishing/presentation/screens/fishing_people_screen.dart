import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/conversation.dart';
import '../../../../data/models/profile.dart';
import '../../../../data/providers/app_providers.dart';
import '../../../../data/providers/planet_providers.dart';
import '../widgets/fishing_glass_panel.dart';
import '../widgets/fishing_mock_data.dart';
import '../widgets/fishing_navigation_rail.dart';

class FishingPeopleScreen extends ConsumerStatefulWidget {
  const FishingPeopleScreen({super.key});

  @override
  ConsumerState<FishingPeopleScreen> createState() => _FishingPeopleScreenState();
}

class _FishingPeopleScreenState extends ConsumerState<FishingPeopleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() => _query = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Profile>> members = ref.watch(
      planetMembersProvider('p_fishing'),
    );
    final String currentUserId = ref.watch(currentUserIdProvider);

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
                        activeLabel: 'Люди',
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
                            child: _content(members, currentUserId),
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

  Widget _content(AsyncValue<List<Profile>> members, String currentUserId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _header(),
        const SizedBox(height: 16),
        _searchField(),
        const SizedBox(height: 20),
        _sectionTitle(),
        const SizedBox(height: 12),
        _members(members, currentUserId),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _header() {
    return FishingGlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            key: const ValueKey<String>('fishing-people-back'),
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
                  Icons.people_outline,
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
                      'Люди сообщества',
                      style: AppTextStyles.headline(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Рыбаки, с которыми можно пообщаться, найти компанию '
                      'и договориться о выезде',
                      style: AppTextStyles.body(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: <Widget>[
              _statChip(Icons.groups_outlined, '${FishingMockData.members} участников'),
              _statChip(Icons.circle, '${FishingMockData.online} онлайн'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: FishingMockData.cyan),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return FishingGlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        key: const ValueKey<String>('fishing-people-search'),
        controller: _searchController,
        style: AppTextStyles.body(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.search, color: FishingMockData.cyan, size: 20),
          hintText: 'Поиск по имени, городу или интересам',
          hintStyle: AppTextStyles.caption(color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _sectionTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Icon(Icons.groups_outlined, color: FishingMockData.cyan, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Участники планеты',
                style: AppTextStyles.title(color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                'Нажмите на профиль или напишите в чат',
                style: AppTextStyles.caption(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _members(AsyncValue<List<Profile>> members, String currentUserId) {
    return members.when(
      loading: () => const FishingGlassPanel(
        key: ValueKey<String>('fishing-people-loading'),
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (Object error, StackTrace stackTrace) => FishingGlassPanel(
        key: const ValueKey<String>('fishing-people-error'),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Не удалось загрузить участников',
              style: AppTextStyles.bodyBold(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              'Попробуйте открыть раздел ещё раз.',
              style: AppTextStyles.caption(),
            ),
          ],
        ),
      ),
      data: (List<Profile> all) {
        final List<Profile> filtered = _query.isEmpty
            ? all
            : all.where((Profile profile) {
                final String haystack = <String>[
                  profile.name,
                  profile.city ?? '',
                  ...profile.interestNames,
                ].join(' ').toLowerCase();
                return haystack.contains(_query.toLowerCase());
              }).toList();

        if (filtered.isEmpty) {
          return FishingGlassPanel(
            key: const ValueKey<String>('fishing-people-empty'),
            padding: const EdgeInsets.all(24),
            child: Text(
              _query.isEmpty
                  ? 'Пока никто не вступил в сообщество. Станьте первым!'
                  : 'Никого не нашли. Попробуйте другой запрос.',
              style: AppTextStyles.body(color: AppColors.textSecondary),
            ),
          );
        }

        return Column(
          key: const ValueKey<String>('fishing-people-list'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final Profile profile in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _memberCard(profile, currentUserId),
              ),
          ],
        );
      },
    );
  }

  Widget _memberCard(Profile profile, String currentUserId) {
    final bool isSelf = profile.id == currentUserId;
    final String details = <String>[
      '${profile.age} лет',
      if (profile.city != null && profile.city!.isNotEmpty) profile.city!,
      if (profile.interestNames.isNotEmpty)
        profile.interestNames.take(2).join(', '),
    ].join(' • ');

    return FishingGlassPanel(
      key: ValueKey<String>('fishing-people-card-${profile.id}'),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AuraAvatar(
                photoUrl: profile.photoUrl,
                size: 52,
                fallbackText: profile.name,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            profile.name,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyBold(color: Colors.white),
                          ),
                        ),
                        if (isSelf) ...<Widget>[
                          const SizedBox(width: 6),
                          Text(
                            '(вы)',
                            style: AppTextStyles.caption(),
                          ),
                        ],
                        if (profile.isOnline && !isSelf) ...<Widget>[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (profile.bio != null && profile.bio!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              profile.bio!,
              style: AppTextStyles.caption(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _cardButton(
                  key: ValueKey<String>('fishing-people-profile-${profile.id}'),
                  icon: Icons.person_outline,
                  label: 'Профиль',
                  color: FishingMockData.cyan,
                  onTap: () => context.push('/user/${profile.id}'),
                ),
              ),
              if (!isSelf) ...<Widget>[
                const SizedBox(width: 8),
                Expanded(
                  child: _cardButton(
                    key: ValueKey<String>('fishing-people-chat-${profile.id}'),
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Чат',
                    color: FishingMockData.accent,
                    onTap: () => _openChat(profile),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardButton({
    required Key key,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openChat(Profile profile) async {
    try {
      final Conversation conversation = await ref
          .read(chatRepositoryProvider)
          .getOrCreateConversation(profile.id);
      if (!mounted) return;
      context.push('/chat/${conversation.id}');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Не удалось открыть чат. Попробуйте ещё раз.'),
          ),
        );
    }
  }
}
