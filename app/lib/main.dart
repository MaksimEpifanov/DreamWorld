import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'data/services/supabase_auth_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseProjectUrl,
    publishableKey: supabasePublishableKey,
  );
  runApp(const ProviderScope(child: DreemWorldApp()));
}
