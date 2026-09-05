import 'package:flutter/material.dart';

/// User-selected locale preference stored in settings.
enum LocalePreference {
  system,
  en,
  vi;

  static LocalePreference fromStorage(String? value) {
    return LocalePreference.values.firstWhere(
      (pref) => pref.name == value,
      orElse: () => LocalePreference.system,
    );
  }
}

class LocaleSupport {
  LocaleSupport._();

  static const supportedLocales = [Locale('en'), Locale('vi')];

  static Locale? materialLocaleFor(LocalePreference preference) {
    return switch (preference) {
      LocalePreference.system => null,
      LocalePreference.en => const Locale('en'),
      LocalePreference.vi => const Locale('vi'),
    };
  }

  static Locale resolveLocale(
    Locale? appLocale,
    Iterable<Locale> deviceLocales,
  ) {
    if (appLocale != null) {
      return _matchSupported(appLocale);
    }

    for (final locale in deviceLocales) {
      if (locale.languageCode == 'vi') {
        return const Locale('vi');
      }
      if (locale.languageCode == 'en') {
        return const Locale('en');
      }
    }

    return const Locale('en');
  }

  static Locale _matchSupported(Locale locale) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }
    return const Locale('en');
  }
}
