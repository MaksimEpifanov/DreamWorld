import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import 'animals_mock_data.dart';

class AnimalsTabs extends StatefulWidget {
  const AnimalsTabs({super.key, this.onTabSelected});

  final ValueChanged<String>? onTabSelected;

  @override
  State<AnimalsTabs> createState() => _AnimalsTabsState();
}

class _AnimalsTabsState extends State<AnimalsTabs> {
  String _active = AnimalsMockData.tabs.first;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final String label in AnimalsMockData.tabs)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                key: ValueKey<String>('animals-tab-$label'),
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
                        ? AnimalsMockData.accent
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: _active == label
                          ? AnimalsMockData.accent
                          : Colors.white.withValues(alpha: 0.12),
                    ),
                    boxShadow: _active == label
                        ? <BoxShadow>[
                            BoxShadow(
                              color: AnimalsMockData.accent.withValues(
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
