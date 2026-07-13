import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Flutter's built-in Material/Widgets/Cupertino localizations only ship
// translations for a fixed set of languages, which doesn't include some of
// this app's supported locales (Lingala 'ln', Kikongo 'kg', Tshiluba 'lua').
// For those, the delegate's isSupported() returns false, so no
// MaterialLocalizations/WidgetsLocalizations/CupertinoLocalizations gets
// registered for that locale at all -- every widget that depends on them
// (essentially all of Material) throws "No MaterialLocalizations found".
// These wrappers claim to support every locale easy_localization does, and
// fall back to French for the underlying widget strings ("OK", date picker
// labels, etc.) when Flutter itself has no translation for the selected
// language. The app's own text (via .tr()) is unaffected: that's handled
// entirely by easy_localization's own delegate, not these.
const _fallback = Locale('fr');

class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final effective = GlobalMaterialLocalizations.delegate.isSupported(locale) ? locale : _fallback;
    return GlobalMaterialLocalizations.delegate.load(effective);
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    final effective = GlobalWidgetsLocalizations.delegate.isSupported(locale) ? locale : _fallback;
    return GlobalWidgetsLocalizations.delegate.load(effective);
  }

  @override
  bool shouldReload(FallbackWidgetsLocalizationsDelegate old) => false;
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final effective = GlobalCupertinoLocalizations.delegate.isSupported(locale) ? locale : _fallback;
    return GlobalCupertinoLocalizations.delegate.load(effective);
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
