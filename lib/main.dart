import 'dart:async';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'repositories/auth_repository.dart';
import 'lab5/screens/auth_pages.dart';
import 'lab5/screens/home_tabs.dart';
import 'lab5/state/auth_controller.dart';
import 'lab5/state/catalog_controller.dart';
import 'lab6/repositories/cloud_catalog_repository.dart';
import 'lab6/state/profile_media_controller.dart';
import 'lab5/state/theme_controller.dart';
import 'lab5/widgets/design_system.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ЛР6: Supabase використовується ЛИШЕ для медіафайлів.
  // Firebase Authentication, Firestore, Analytics та Crashlytics збережено.
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  }

  // Збережено інтеграції Analytics / Crashlytics із лабораторної №4.
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  try {
    await FirebaseAnalytics.instance.logEvent(name: 'jobcatalog_opened');
  } catch (_) {
    // Аналітика не повинна блокувати запуск.
  }

  final theme = ThemeController();
  await theme.load();
  final catalog = CatalogController(repository: CloudCatalogRepository());
  // Дані каталогу завантажуються для поточного Firebase UID в AuthGate.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>.value(value: theme),
        ChangeNotifierProvider<CatalogController>.value(value: catalog),
        ChangeNotifierProvider<ProfileMediaController>(
          create: (_) => ProfileMediaController(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(AuthRepository()),
        ),
      ],
      child: const JobCatalogApp(),
    ),
  );
}

class JobCatalogApp extends StatelessWidget {
  const JobCatalogApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Job Catalog',
    debugShowCheckedModeBanner: false,
    theme: makeJobTheme(Brightness.light),
    darkTheme: makeJobTheme(Brightness.dark),
    themeMode: context.watch<ThemeController>().themeMode,
    home: const AuthGate(),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => Consumer<AuthController>(
    builder: (context, auth, child) {
      if (!auth.initialized) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      // Не показувати дані попереднього акаунта навіть протягом одного кадру.
      final catalog = context.watch<CatalogController>();
      final uid = auth.user?.uid;
      if (!catalog.isReadyFor(uid)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          final currentUid = context.read<AuthController>().user?.uid;
          unawaited(context.read<CatalogController>().loadForUser(currentUid));
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return auth.signedIn ? const HomeTabs() : const AuthPage();
    },
  );
}
