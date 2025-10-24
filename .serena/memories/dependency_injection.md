# Dependency Injection & Providers

## Overview

The project uses **Flutter Riverpod** for dependency injection and state management. All providers are centralized in `/lib/core/di/providers.dart`.

## Provider Hierarchy

### 1. Core Services

#### HiveServiceProvider

```dart
final hiveServiceProvider = Provider<HiveService>((ref) => HiveService.instance);
```

- Singleton instance of HiveService
- Handles Hive initialization, box opening/closing
- Supports encrypted and non-encrypted boxes

#### SettingsBoxProvider

```dart
final settingsBoxProvider = FutureProvider<Box>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  return await hiveService.openBox(AppConstants.settingsBoxName);
});
```

- Opens non-encrypted settings box
- Stores app preferences and encryption keys

#### EncryptionKeyProvider

```dart
final encryptionKeyProvider = FutureProvider<List<int>>((ref) async {
  final settingsBox = await ref.watch(settingsBoxProvider.future);
  // Generate or retrieve encryption key
  return encryptionKey;
});
```

- Generates secure AES encryption key if not exists
- Stores key in settings box for persistence
- Used for encrypting cycle data

### 2. Data Layer Providers

#### CycleBoxProvider

```dart
final cycleBoxProvider = FutureProvider<Box<CycleModel>>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  final encryptionKey = await ref.watch(encryptionKeyProvider.future);
  return await hiveService.openEncryptedBox<CycleModel>(
    AppConstants.cycleBoxName,
    encryptionKey,
  );
});
```

- Opens encrypted Hive box for CycleModel storage
- Uses HiveAesCipher with generated encryption key

#### CycleLocalDataSourceProvider

```dart
final cycleLocalDataSourceProvider = FutureProvider<CycleLocalDataSource>((ref) async {
  final cycleBox = await ref.watch(cycleBoxProvider.future);
  return CycleLocalDataSource(cycleBox);
});
```

- Provides access to local data operations (CRUD)

#### CycleRepositoryProvider

```dart
final cycleRepositoryProvider = FutureProvider<CycleRepository>((ref) async {
  final dataSource = await ref.watch(cycleLocalDataSourceProvider.future);
  return CycleRepositoryImpl(dataSource);
});
```

- Implements domain repository interface
- Acts as abstraction layer between data source and use cases

### 3. Use Case Providers

#### Cycle Management

- `addCycleUseCaseProvider` - Add new cycle
- `updateCycleUseCaseProvider` - Update existing cycle
- `deleteCycleUseCaseProvider` - Delete cycle
- `getCyclesUseCaseProvider` - Get all cycles
- `getCyclesInRangeUseCaseProvider` - Get cycles in date range

#### Prediction Use Cases

- `calculateAverageUseCaseProvider` - Calculate simple average cycle length
- `calculateWeightedAverageUseCaseProvider` - Calculate weighted average (recent cycles weighted more)
- `predictNextCycleUseCaseProvider` - Predict next cycle start date

#### Statistics Use Cases

- `calculateStandardDeviationUseCaseProvider` - Calculate cycle length std deviation
- `checkCycleRegularityUseCaseProvider` - Check if cycles are regular
- `calculateDaysUntilNextPeriodUseCaseProvider` - Days until predicted next period
- `calculateRegularityScoreUseCaseProvider` - Score from 0-100 for regularity
- `getCycleStatisticsUseCaseProvider` - Get comprehensive statistics

### 4. ViewModel Providers

#### CycleListProvider

```dart
final cycleListProvider = StateNotifierProvider<CycleListNotifier, CycleListState>((ref) {
  // Provides cycle list state management
});
```

- Manages cycle list state (loading, loaded, error)
- Handles CRUD operations
- Notifies UI of state changes

#### ThemeModeProvider

```dart
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  // Manages theme mode (light/dark)
});
```

- Persists theme preference
- Notifies UI of theme changes

## Dependency Flow

```
UI (ConsumerWidget)
  ↓
ViewModel (StateNotifier)
  ↓
UseCase (Business Logic)
  ↓
Repository (Interface)
  ↓
Repository Implementation
  ↓
DataSource (Hive Operations)
  ↓
Hive Box (Encrypted Storage)
```

## Key Features

### Lazy Initialization

- All providers use `FutureProvider` for async initialization
- Resources loaded only when needed

### Dependency Injection

- No manual dependency passing
- Clean separation of concerns
- Easy testing with provider overrides

### Encryption Key Management

- Automatic key generation on first run
- Secure storage in settings box
- Transparent encryption/decryption

## Usage Example

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch cycle list state
    final cycleState = ref.watch(cycleListProvider);

    // Access use case for operations
    final addCycleUseCase = ref.watch(addCycleUseCaseProvider);

    return // UI code
  }
}
```

## Best Practices

1. **Use FutureProvider** for async resources
2. **Use StateNotifierProvider** for mutable state
3. **Watch dependencies** in build method
4. **Read providers** for one-time operations
5. **Override providers** for testing
