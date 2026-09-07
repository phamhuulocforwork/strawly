import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:strawly/core/constants/app_constants.dart';
import 'package:strawly/core/di/hive_service.dart';
import 'package:strawly/core/l10n/locale_support.dart';
import 'package:strawly/presentation/viewmodels/live_island_settings_viewmodel.dart';
import 'package:strawly/presentation/viewmodels/locale_viewmodel.dart';
import 'package:strawly/presentation/viewmodels/theme_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDir;
  late ProviderContainer container;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('strawly_hive_startup');
    Hive.init(hiveDir.path);
    container = ProviderContainer();
  });

  tearDown(() async {
    try {
      await container.read(settingsBoxProvider.future);
    } catch (_) {}
    container.dispose();
    await Hive.close();
    if (hiveDir.existsSync()) {
      await hiveDir.delete(recursive: true);
    }
  });

  test(
    'first-frame settings providers do not throw before settingsBoxProvider completes',
    () {
      expect(Hive.isBoxOpen(AppConstants.settingsBoxName), isFalse);

      expect(() => container.read(themeModeProvider), returnsNormally);
      expect(() => container.read(localePreferenceProvider), returnsNormally);
      expect(() => container.read(liveIslandEnabledProvider), returnsNormally);

      expect(container.read(themeModeProvider), ThemeMode.system);
      expect(container.read(localePreferenceProvider), LocalePreference.system);
      expect(container.read(liveIslandEnabledProvider), isTrue);
    },
  );

  test('ensureCoreBoxesOpen makes first-frame providers read saved settings', () async {
    await HiveService.instance.ensureCoreBoxesOpen();

    expect(Hive.isBoxOpen(AppConstants.settingsBoxName), isTrue);
    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(container.read(localePreferenceProvider), LocalePreference.system);
    expect(container.read(liveIslandEnabledProvider), isTrue);
  });
}
