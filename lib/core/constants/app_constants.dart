class AppConstants {
  AppConstants._();

  // Database
  static const String cycleBoxName = 'cycles';
  static const String settingsBoxName = 'settings';

  // Encryption
  static const String encryptionKeyKey = 'encryption_key';

  // Settings Keys
  static const String isDarkModeKey = 'is_dark_mode';
  static const String localePreferenceKey = 'locale_preference';
  static const String isPinEnabledKey = 'is_pin_enabled';
  static const String userPinKey = 'user_pin';
  static const String isBiometricEnabledKey = 'is_biometric_enabled';
  static const String liveIslandEnabledKey = 'live_island_enabled';

  // OS Live Activity / Super Island (decorative, process-bound)
  static const String liveIslandActivityId = 'strawly-cycle';
  static const String liveIslandAppGroupId = 'group.com.example.strawly';
  static const String liveIslandUrlScheme = 'strawly';

  // Cycle Prediction
  static const int defaultCycleLength = 28;
  static const int minCycleLength = 21;
  static const int maxCycleLength = 35;
  static const int periodDuration = 5; // Average period duration in days
  static const int cyclesToConsider =
      6; // Number of recent cycles for prediction
  static const int recentCyclesLimit = 5;

  // Statistics
  static const int regularCycleVariation =
      3; // Days variation for regular cycles
}
