import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/cycle_model.dart';
import '../constants/app_constants.dart';

class HiveService {
  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._();

  HiveService._();

  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CycleModelAdapter());
      }

      _isInitialized = true;
    }

    await ensureCoreBoxesOpen();
  }

  /// Opens boxes that first-frame providers read via [Hive.box].
  Future<void> ensureCoreBoxesOpen() async {
    if (!Hive.isBoxOpen(AppConstants.settingsBoxName)) {
      await openBox(AppConstants.settingsBoxName);
    }
  }

  Box? peekOpenSettingsBox() {
    if (!Hive.isBoxOpen(AppConstants.settingsBoxName)) {
      return null;
    }
    return Hive.box(AppConstants.settingsBoxName);
  }

  Future<Box<T>> openEncryptedBox<T>(
    String boxName,
    List<int> encryptionKey,
  ) async {
    return await Hive.openBox<T>(
      boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<Box<T>> openBox<T>(String boxName) async {
    return await Hive.openBox<T>(boxName);
  }

  Future<void> closeAll() async {
    await Hive.close();
  }

  Future<void> deleteBox(String boxName) async {
    await Hive.deleteBoxFromDisk(boxName);
  }
}

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService.instance;
});

final settingsBoxProvider = FutureProvider<Box>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  return await hiveService.openBox(AppConstants.settingsBoxName);
});

/// Settings box for sync providers. Null only while [settingsBoxProvider] is
/// still opening and [HiveService.ensureCoreBoxesOpen] has not run yet.
Box? resolvedSettingsBox(Ref ref) {
  return ref.watch(settingsBoxProvider).value ??
      ref.read(hiveServiceProvider).peekOpenSettingsBox();
}
