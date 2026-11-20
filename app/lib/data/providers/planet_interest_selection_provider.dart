import 'package:flutter_riverpod/flutter_riverpod.dart';

final StateProviderFamily<Set<String>, String>
selectedPlanetInterestsProvider = StateProvider.family<Set<String>, String>(
  (Ref ref, String planetId) => <String>{},
);

void toggleSelectedPlanetInterest(
  WidgetRef ref,
  String planetId,
  String item,
) {
  final StateProvider<Set<String>> provider =
      selectedPlanetInterestsProvider(planetId);
  final Set<String> next = <String>{...ref.read(provider)};
  if (!next.remove(item)) next.add(item);
  ref.read(provider.notifier).state = next;
}
