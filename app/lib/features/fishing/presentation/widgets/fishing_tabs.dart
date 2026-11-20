import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import 'fishing_mock_data.dart';

class FishingTabs extends StatefulWidget {
  const FishingTabs({super.key, this.onTabSelected});

  final ValueChanged<String>? onTabSelected;

  @override
  State<FishingTabs> createState() => _FishingTabsState();
}

class _FishingTabsState extends State<FishingTabs> {
  String _active = FishingMockData.tabs.first;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final String label in FishingMockData.tabs)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                key: ValueKey<String>('fishing-tab-$label'),
                onTap: () {
                  setState(() => _active = label);
                  widget.onTabSelected?.call(label);
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _active == label
                        ? FishingMockData.accent
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: _active == label
                          ? FishingMockData.accent
                          : Colors.white.withValues(alpha: 0.12),
                    ),
                    boxShadow: _active == label
                        ? <BoxShadow>[
                            BoxShadow(
                              color: FishingMockData.accent.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 14,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    label,
                    style: AppTextStyles.label(
                      color: _active == label
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
}
