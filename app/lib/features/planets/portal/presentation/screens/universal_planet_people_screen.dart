import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/index.dart';
import '../../../../../core/widgets/index.dart';
import '../../../../../data/models/conversation.dart';
import '../../../../../data/models/profile.dart';
import '../../../../../data/providers/app_providers.dart';
import '../../../../../data/providers/planet_providers.dart';
import '../../data/portal_catalog.dart';
import '../widgets/portal_glass_panel.dart';
import '../widgets/portal_navigation_rail.dart';

class UniversalPlanetPeopleScreen extends ConsumerStatefulWidget {
  const UniversalPlanetPeopleScreen({super.key, required this.planetId});

  final String planetId;

  @override
  ConsumerState<UniversalPlanetPeopleScreen> createState() =>
      _UniversalPlanetPeopleScreenState();
}

class _UniversalPlanetPeopleScreenState
    extends ConsumerState<UniversalPlanetPeopleScreen> {
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
      planetMembersProvider(widget.planetId),
    );
    final String currentUserId = ref.watch(currentUserIdProvider);

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
    return PortalGlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            key: ValueKey<String>('portal-people-back-${widget.planetId}'),
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
                      'Участники планеты «${PortalCatalog.title(widget.planetId)}», '
                      'с которыми можно общаться и делиться опытом',
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
              _statChip(
                Icons.groups_outlined,
                '${PortalCatalog.members(widget.planetId)} участников',
              ),
              _statChip(
                Icons.circle,
                '${PortalCatalog.online(widget.planetId)} онлайн',
              ),
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
          Icon(icon, size: 14, color: PortalCatalog.cyan),
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
    return PortalGlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        key: ValueKey<String>('portal-people-search-${widget.planetId}'),
        controller: _searchController,
        style: AppTextStyles.body(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.search, color: PortalCatalog.cyan, size: 20),
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
        const Icon(Icons.groups_outlined, color: PortalCatalog.cyan, size: 20),
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
      loading: () => PortalGlassPanel(
        key: ValueKey<String>('portal-people-loading-${widget.planetId}'),
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (Object error, StackTrace stackTrace) => PortalGlassPanel(
        key: ValueKey<String>('portal-people-error-${widget.planetId}'),
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
          return PortalGlassPanel(
            key: ValueKey<String>('portal-people-empty-${widget.planetId}'),
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
          key: ValueKey<String>('portal-people-list-${widget.planetId}'),
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

    return PortalGlassPanel(
      key: ValueKey<String>(
        'portal-people-card-${widget.planetId}-${profile.id}',
      ),
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
                          Text('(вы)', style: AppTextStyles.caption()),
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
                      style: AppTextStyles.caption(
                        color: AppColors.textSecondary,
                      ),
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
                  key: ValueKey<String>(
                    'portal-people-profile-${widget.planetId}-${profile.id}',
                  ),
                  icon: Icons.person_outline,
                  label: 'Профиль',
                  color: PortalCatalog.cyan,
                  onTap: () => context.push('/user/${profile.id}'),
                ),
              ),
              if (!isSelf) ...<Widget>[
                const SizedBox(width: 8),
                Expanded(
                  child: _cardButton(
                    key: ValueKey<String>(
                      'portal-people-chat-${widget.planetId}-${profile.id}',
                    ),
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Чат',
                    color: PortalCatalog.accent,
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
