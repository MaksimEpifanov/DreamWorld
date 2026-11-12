import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/neon_button.dart';
import '../../core/widgets/responsive_content.dart';
import 'widgets/neon_logo_text.dart';

class OnboardingPage {
  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  List<OnboardingPage> _pages(BuildContext context) => <OnboardingPage>[
    OnboardingPage(
      title: 'Знакомства по совместимости',
      description: 'Умный подбор на основе интересов, ценностей и целей',
      icon: Icons.favorite_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
    ),
    OnboardingPage(
      title: 'Чат + перевод',
      description: 'Коммуницируй без языковых барьеров в реальном времени',
      icon: Icons.chat_bubble_rounded,
      iconColor: Theme.of(context).colorScheme.secondary,
    ),
    OnboardingPage(
      title: 'ИИ-помощник',
      description: 'Советы, переформулировки и ледоколы для общения',
      icon: Icons.auto_awesome_rounded,
      iconColor: Theme.of(context).colorScheme.tertiary,
    ),
    OnboardingPage(
      title: 'Твоя история начинается',
      description: 'Создай профиль и найди тех, кто близок по духу',
      icon: Icons.celebration_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    final List<OnboardingPage> pages = _pages(context);
    if (_currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/register');
    }
  }

  void _skip() {
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    final List<OnboardingPage> pages = _pages(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildDecorativeCircles(scheme),
          SafeArea(
            child: ResponsiveContent(
              child: Padding(
                padding: AppSpacing.page,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: NeonLogoText(fontSize: 28),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _skip,
                          child: Text(
                            'Пропустить',
                            style: AppTextStyles.body(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        onPageChanged: (int index) {
                          setState(() => _currentPage = index);
                        },
                        itemCount: pages.length,
                        itemBuilder: (BuildContext context, int index) {
                          final OnboardingPage page = pages[index];
                          return LayoutBuilder(
                            builder:
                                (
                                  BuildContext context,
                                  BoxConstraints constraints,
                                ) {
                                  return SingleChildScrollView(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: <Color>[
                                                  (page.iconColor ??
                                                          scheme.primary)
                                                      .withValues(alpha: 0.4),
                                                  (page.iconColor ??
                                                          scheme.primary)
                                                      .withValues(alpha: 0.1),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                            child:
                                                Icon(
                                                      page.icon,
                                                      size: 64,
                                                      color:
                                                          page.iconColor ??
                                                          scheme.primary,
                                                    )
                                                    .animate(
                                                      key: ValueKey<String>(
                                                        'icon-$index',
                                                      ),
                                                    )
                                                    .scale(
                                                      begin: const Offset(
                                                        0.6,
                                                        0.6,
                                                      ),
                                                      end: const Offset(1, 1),
                                                      duration: 500.ms,
                                                      curve: Curves.easeOutBack,
                                                    )
                                                    .fadeIn(duration: 400.ms),
                                          ),
                                          const SizedBox(height: AppSpacing.xl),
                                          Text(
                                                page.title,
                                                style: AppTextStyles.title()
                                                    .copyWith(fontSize: 22),
                                                textAlign: TextAlign.center,
                                              )
                                              .animate(
                                                key: ValueKey<String>(
                                                  'title-$index',
                                                ),
                                              )
                                              .fadeIn(
                                                delay: 100.ms,
                                                duration: 400.ms,
                                              )
                                              .slideY(
                                                begin: 0.3,
                                                end: 0,
                                                duration: 400.ms,
                                                curve: Curves.easeOut,
                                              ),
                                          const SizedBox(height: AppSpacing.md),
                                          Text(
                                                page.description,
                                                style: AppTextStyles.body(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                                textAlign: TextAlign.center,
                                              )
                                              .animate(
                                                key: ValueKey<String>(
                                                  'description-$index',
                                                ),
                                              )
                                              .fadeIn(
                                                delay: 200.ms,
                                                duration: 400.ms,
                                              )
                                              .slideY(
                                                begin: 0.3,
                                                end: 0,
                                                duration: 400.ms,
                                                curve: Curves.easeOut,
                                              ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                        pages.length,
                        (int index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: _currentPage == index ? 28 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: _currentPage == index
                                ? LinearGradient(
                                    colors: <Color>[
                                      scheme.primary,
                                      scheme.secondary,
                                    ],
                                  )
                                : null,
                            color: _currentPage == index
                                ? null
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.3,
                                  ),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            boxShadow: _currentPage == index
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: scheme.primary.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    NeonButton(
                      onPressed: _next,
                      label: _currentPage == pages.length - 1
                          ? 'Начать'
                          : 'Далее',
                      expanded: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircles(ColorScheme scheme) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: -100,
          left: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          right: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.secondary.withValues(alpha: 0.08),
            ),
          ),
        ),
      ],
    );
  }
}
