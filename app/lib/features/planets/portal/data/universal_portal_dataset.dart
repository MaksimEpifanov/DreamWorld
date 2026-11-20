import 'package:flutter/material.dart';

class PortalTypeInfo {
  const PortalTypeInfo({
    required this.title,
    required this.category,
    required this.icon,
    required this.short,
    required this.description,
    required this.gear,
    required this.extras,
    required this.place,
    required this.tip,
  });

  final String title;
  final String category;
  final IconData icon;
  final String short;
  final String description;
  final List<String> gear;
  final List<String> extras;
  final String place;
  final String tip;
}

class PortalTip {
  const PortalTip({required this.title, required this.body, required this.icon});

  final String title;
  final String body;
  final IconData icon;
}

class PortalMistake {
  const PortalMistake({
    required this.title,
    required this.body,
    required this.fix,
    required this.icon,
  });

  final String title;
  final String body;
  final String fix;
  final IconData icon;
}

class PortalSafetyRule {
  const PortalSafetyRule({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}

class PortalSource {
  const PortalSource({required this.title, required this.url});

  final String title;
  final String url;
}

class PortalDataset {
  const PortalDataset({
    required this.planetId,
    required this.kindsLabel,
    required this.categories,
    required this.types,
    required this.tips,
    required this.mistakes,
    required this.safety,
    required this.sources,
  });

  final String planetId;
  final String kindsLabel;
  final List<String> categories;
  final List<PortalTypeInfo> types;
  final List<PortalTip> tips;
  final List<PortalMistake> mistakes;
  final List<PortalSafetyRule> safety;
  final List<PortalSource> sources;
}
