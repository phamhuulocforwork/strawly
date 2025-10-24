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
    if (_isInitialized) return;

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CycleModelAdapter());
    }

    _isInitialized = true;
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
