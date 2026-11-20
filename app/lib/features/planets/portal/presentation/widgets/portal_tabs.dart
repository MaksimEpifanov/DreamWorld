import 'package:flutter/material.dart';

import '../../../../../core/theme/index.dart';
import '../../data/portal_catalog.dart';

class PortalTabs extends StatefulWidget {
  const PortalTabs({
    super.key,
    required this.planetId,
    this.onTabSelected,
  });

  final String planetId;
  final ValueChanged<String>? onTabSelected;

  @override
  State<PortalTabs> createState() => _PortalTabsState();
}

class _PortalTabsState extends State<PortalTabs> {
  late String _active;

  @override
  void initState() {
    super.initState();
    _active = PortalCatalog.tabs(widget.planetId).first;
  }

  @override
  void didUpdateWidget(PortalTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.planetId != widget.planetId) {
      setState(() => _active = PortalCatalog.tabs(widget.planetId).first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = PortalCatalog.tabs(widget.planetId);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final String label in tabs)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                key: ValueKey<String>('portal-tab-$label'),
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
                        ? PortalCatalog.accent
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: _active == label
                          ? PortalCatalog.accent
                          : Colors.white.withValues(alpha: 0.12),
                    ),
                    boxShadow: _active == label
                        ? <BoxShadow>[
                            BoxShadow(
                              color: PortalCatalog.accent.withValues(
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
