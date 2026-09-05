import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'core/di/hive_service.dart';
import 'core/l10n/locale_support.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/shell/app_shell.dart';
import 'presentation/viewmodels/locale_viewmodel.dart';
import 'presentation/viewmodels/theme_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('en');
  await initializeDateFormatting('vi');
  await HiveService.instance.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final localePreference = ref.watch(localePreferenceProvider);
    final appLocale = LocaleSupport.materialLocaleFor(localePreference);

    return ShadApp.custom(
      themeMode: themeMode,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      appBuilder: (context) {
        return MaterialApp(
          title: 'Strawly - Menstrual Cycle Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getMaterialTheme(
            themeMode == ThemeMode.dark
                ? AppTheme.darkTheme()
                : AppTheme.lightTheme(),
          ),
          darkTheme: AppTheme.getMaterialTheme(AppTheme.darkTheme()),
          themeMode: themeMode,
          locale: appLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: LocaleSupport.supportedLocales,
          localeListResolutionCallback: (locales, supportedLocales) {
            return LocaleSupport.resolveLocale(
              appLocale,
              locales ?? const [Locale('en')],
            );
          },
          home: const AppShell(),
          builder: (context, child) {
            return ShadAppBuilder(child: child!);
          },
        );
      },
    );
  }
}
