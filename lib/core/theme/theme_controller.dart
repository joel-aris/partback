import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _restore();
    return ThemeMode.system;
  }

  Future<void> _restore() async {
    final saved = await ref.read(preferencesStorageProvider).readThemeMode();
    if (saved == null) return;
    state = ThemeMode.values.firstWhere((mode) => mode.name == saved, orElse: () => ThemeMode.system);
  }

  void toggle() {
    final isDark = state == ThemeMode.dark || (state == ThemeMode.system && _platformIsDark());
    setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  void setMode(ThemeMode mode) {
    state = mode;
    ref.read(preferencesStorageProvider).writeThemeMode(mode.name);
  }

  bool _platformIsDark() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }
}
