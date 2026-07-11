import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

const supportedLocales = [
  Locale('fr'),
  Locale('en'),
  Locale('ln'),
  Locale('sw'),
  Locale('kg'),
  Locale('lua'),
];

const _localeLabels = {
  'fr': 'Francais',
  'en': 'English',
  'ln': 'Lingala',
  'sw': 'Kiswahili',
  'kg': 'Kikongo',
  'lua': 'Tshiluba',
};

/// Language switcher shown in the top-level app bars (cahier des charges 4.1).
class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.locale;

    return PopupMenuButton<Locale>(
      tooltip: 'common.language'.tr(),
      icon: const Icon(Icons.translate_rounded),
      initialValue: current,
      onSelected: (locale) => context.setLocale(locale),
      itemBuilder: (context) => supportedLocales
          .map(
            (locale) => PopupMenuItem(
              value: locale,
              child: Row(
                children: [
                  if (locale == current) const Icon(Icons.check_rounded, size: 18) else const SizedBox(width: 18),
                  const SizedBox(width: 8),
                  Text(_localeLabels[locale.languageCode] ?? locale.languageCode),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
