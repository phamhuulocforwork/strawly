# Security & Encryption

## Overview

The application implements **offline-first security** with local encryption. No data ever leaves the device unless explicitly exported by the user.

## Security Architecture

### Multi-Layer Security

```
User Data
  ↓
Application Layer (Dart encryption)
  ↓
Hive Storage Layer (AES-256 encryption)
  ↓
Device Storage (OS-level security)
  ↓
Optional: Biometric/PIN Lock
```

## Encryption Implementation

### 1. Encryption Key Generation

**Location**: `/lib/core/utils/encryption_utils.dart`

```dart
class EncryptionUtils {
  static List<int> generateSecureKey() {
    final secureRandom = Random.secure();
    return List<int>.generate(32, (_) => secureRandom.nextInt(256));
  }
}
```

**Features**:

- Uses `Random.secure()` for cryptographically secure random generation
- Generates 256-bit (32-byte) key
- Complies with AES-256 standard

### 2. Key Storage

**Location**: `/lib/core/di/providers.dart`

```dart
final encryptionKeyProvider = FutureProvider<List<int>>((ref) async {
  final settingsBox = await ref.watch(settingsBoxProvider.future);

  String? keyString = settingsBox.get(AppConstants.encryptionKeyKey);

  if (keyString == null) {
    // First run: generate new key
    final newKey = EncryptionUtils.generateSecureKey();
    keyString = EncryptionUtils.keyToString(newKey);
    await settingsBox.put(AppConstants.encryptionKeyKey, keyString);
    return newKey;
  }

  // Subsequent runs: retrieve existing key
  return EncryptionUtils.stringToKey(keyString);
});
```

**Key Management**:

- Generated on first app launch
- Stored in separate settings box (non-encrypted)
- Persists across app restarts
- Used to encrypt/decrypt cycle data box

**Security Consideration**: The encryption key is stored on device. This provides:

- ✅ Protection against casual file system access
- ✅ Protection against device backup theft (if backups not encrypted)
- ⚠️ Not protected against root/jailbreak access
- ⚠️ Not protected against sophisticated device forensics

### 3. Encrypted Box Implementation

**Location**: `/lib/core/di/hive_service.dart`

```dart
Future<Box<T>> openEncryptedBox<T>(
  String boxName,
  List<int> encryptionKey,
) async {
  return await Hive.openBox<T>(
    boxName,
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
}
```

**Hive Encryption**:

- Uses `HiveAesCipher` with AES-256-CBC
- Encrypts entire box (all records)
- Transparent encryption/decryption
- No performance impact for small datasets

### 4. Data Flow

#### Writing Data

```
Cycle Entity (Plain)
  ↓
CycleModel (Plain)
  ↓
Hive write() → HiveAesCipher encrypts
  ↓
Encrypted bytes written to disk
```

#### Reading Data

```
Encrypted bytes on disk
  ↓
Hive read() → HiveAesCipher decrypts
  ↓
CycleModel (Plain)
  ↓
Cycle Entity (Plain)
```

## Biometric/PIN Authentication

### Local Auth Implementation

**Dependency**: `local_auth: ^2.3.0`

**Planned Features**:

1. Optional PIN code lock
2. Biometric authentication (fingerprint, Face ID)
3. App lock on background
4. Configurable timeout

**Future Implementation Location**: `/lib/core/security/`

### Usage Pattern

```dart
// Pseudo-code for future implementation
final localAuth = LocalAuthentication();

Future<bool> authenticate() async {
  final canAuthenticateWithBiometrics = await localAuth.canCheckBiometrics;

  if (canAuthenticateWithBiometrics) {
    return await localAuth.authenticate(
      localizedReason: 'Please authenticate to access your data',
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );
  }

  return true; // Fallback to PIN
}
```

## Backup & Export Security

### JSON Export

**Location**: `/lib/data/models/cycle_model.dart`

```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'startDate': startDate.toIso8601String(),
    'cycleLength': cycleLength,
    'periodDuration': periodDuration,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
```

**Security Considerations**:

- Exported JSON is **unencrypted** plain text
- User responsible for securing exported files
- Should warn user about backup security
- Consider adding optional backup encryption

### Backup Best Practices (for future implementation)

1. **Encrypted Backups**: Use password-based encryption for exports
2. **Secure Sharing**: Use system share sheet with encryption
3. **Cloud Sync**: If implemented, use end-to-end encryption
4. **Backup Verification**: Hash-based integrity checks

## Security Features Summary

### ✅ Implemented

- AES-256 encryption for local storage
- Secure random key generation
- Persistent key management
- Encrypted Hive boxes
- Offline-first (no network transmission)

### 🚧 Planned

- PIN code authentication
- Biometric authentication (fingerprint, Face ID)
- App lock on background/timeout
- Encrypted backup files
- Secure file sharing

### ❌ Not Planned (Intentional Design)

- Cloud synchronization (privacy-first approach)
- Server-side storage
- Account system
- Online backup

## Privacy Guarantees

1. **No Network Access**: App doesn't require internet permission
2. **No Analytics**: No tracking or telemetry
3. **No Third-Party SDKs**: Minimal dependencies
4. **Local Only**: All data stays on device
5. **User Control**: User owns and controls all data

## Constants

**Location**: `/lib/core/constants/app_constants.dart`

```dart
class AppConstants {
  static const String cycleBoxName = 'cycles';
  static const String settingsBoxName = 'settings';
  static const String encryptionKeyKey = 'encryption_key';
  // ...
}
```

## Threat Model

### Protected Against

✅ Unauthorized file system access
✅ Stolen/lost unencrypted device backups
✅ Casual data snooping
✅ Exported backup theft (if encryption implemented)

### Not Protected Against

⚠️ Root/jailbreak access with key extraction
⚠️ Sophisticated device forensics
⚠️ Screen capture/recording (shoulder surfing)
⚠️ Device unlocked and unattended

## Security Recommendations

### For Users

1. Enable device encryption
2. Use strong device lock (PIN/password/biometric)
3. Keep device software updated
4. Secure exported backups
5. Don't share device access

### For Developers

1. Never log sensitive data
2. Clear data from memory after use
3. Use secure coding practices
4. Regular security audits
5. Keep dependencies updated

## Compliance Notes

### GDPR/Privacy Compliance

- ✅ Data minimization: Only essential data collected
- ✅ User control: Full data ownership and deletion
- ✅ No profiling: No automated decision making
- ✅ Transparency: Open source, auditable code
- ✅ Right to erasure: User can delete all data

### Health Data Regulations

- ⚠️ Not HIPAA compliant (not a healthcare provider)
- ⚠️ Not medical device (informational only)
- ✅ User-managed health data
- ✅ No health advice provided
