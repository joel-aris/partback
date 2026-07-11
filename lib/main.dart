import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/language_menu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: supportedLocales,
        path: 'assets/translations',
        fallbackLocale: const Locale('fr'),
        startLocale: const Locale('fr'),
        child: const ValidikaApp(),
      ),
    ),
  );
}

class ValidikaApp extends ConsumerWidget {
  const ValidikaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      // go_router's StatefulShellRoute deliberately keeps the shell (bottom
      // nav) alive across rebuilds to preserve each tab's navigation stack,
      // which means widgets using the .tr() string extension in there (e.g.
      // AppShell's labels) don't refresh on their own when the locale
      // changes. Keying on the locale forces a full remount when it does.
      key: ValueKey(context.locale),
      title: 'VALIDIKA',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
