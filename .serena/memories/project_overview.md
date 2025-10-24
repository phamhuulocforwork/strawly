# Strawly - Project Overview

## Project Description

Strawly is an offline-first Flutter application for menstrual cycle tracking that allows users to:

- Record menstrual cycle history
- Predict the next period based on historical data
- Display calendar, statistical charts, and basic health information
- Ensure absolute security with encrypted local data storage

## Software Architecture

### Clean Architecture + MVVM + Riverpod

```
lib/
├── data/          ← Storage, repository, model, local DB
├── domain/        ← Business logic (use cases, entities)
├── presentation/  ← UI, view model, state management
└── core/          ← Constants, helpers, theme, utils, dependency injection
```

### Data Flow

```
UI → ViewModel → UseCase → Repository → Local DataSource → Hive
↑                                                   ↓
└───────────── display results (cycles, predictions, statistics)
```

## Core Technologies

### Dependencies

- **UI Framework**: Flutter + shadcn_ui (v0.38.5)
- **State Management**: flutter_riverpod (v2.6.1)
- **Local Storage**: hive (v2.2.3) + hive_flutter (v1.1.0)
- **Encryption**: encrypt (v5.0.3)
- **Date/Time**: intl (v0.20.2)
- **Charts**: fl_chart (v0.69.2)
- **Security**: local_auth (v2.3.0)
- **Icons**: lucide_icons_flutter (v3.0.0)
- **Utilities**: equatable, uuid, path_provider

### Dev Dependencies

- flutter_lints (v5.0.0)
- hive_generator (v2.0.1)
- build_runner (v2.4.13)

## Main Directory Structure

### /lib/core

- **constants/**: app_constants.dart, hive_type_ids.dart
- **di/**: providers.dart, hive_service.dart (dependency injection)
- **theme/**: app_theme.dart (light/dark theme)
- **utils/**: date_time_utils.dart, encryption_utils.dart

### /lib/data

- **datasources/**: cycle_local_datasource.dart (Hive operations)
- **models/**: cycle_model.dart (Hive model with @HiveType)
- **repositories/**: cycle_repository_impl.dart (implements domain repository)

### /lib/domain

- **entities/**: cycle.dart, cycle_statistics.dart (business entities)
- **repositories/**: cycle_repository.dart (abstract interface)
- **usecases/**:
  - cycle_usecases.dart (AddCycleUseCase, UpdateCycleUseCase, DeleteCycleUseCase)
  - prediction_usecases.dart (dự đoán chu kỳ tiếp theo)
  - statistics_usecases.dart (tính toán thống kê)

### /lib/presentation

- **screens/**:
  - home_screen.dart (main screen with calendar)
  - add_cycle_screen.dart (add new cycle)
  - statistics_screen.dart (display statistics)
  - settings_screen.dart (settings)
- **viewmodels/**:
  - cycle_viewmodel.dart (CycleListNotifier manages cycle state)
  - theme_viewmodel.dart (ThemeModeNotifier manages dark/light mode)
- **widgets/**:
  - cycle_calendar_widget.dart (calendar widget displaying cycles)
  - prediction_card_widget.dart (card displaying prediction)

## Main Business Logic

### 1. Enter New Cycle

- Save CycleModel (start date, length, notes)
- Validation: prevent duplicate cycles

### 2. Calculate Average Cycle Length

- Based on historical data
- Uses Moving Average or Weighted Average

### 3. Predict Next Cycle

- `nextStartDate = lastStartDate + avgLength`
- No complex ML, based on simple average

### 4. Statistics

- Trend charts
- Standard deviation
- Regular/irregular cycle ratio

### 5. Data Security

- Store with Hive + AES encryption (HiveAesCipher)
- No cloud sync
- Manual backup/restore via JSON
- Optional PIN or biometric app lock

## UI/UX

### Theme

- Soft pastel color tones
- Light/Dark mode support
- Uses shadcn_ui components

### Main Screens

1. **Home**: Calendar + prediction information
2. **Add Cycle**: Enter new cycle
3. **Statistics**: Charts, regularity ratio
4. **Settings**: Security, data export

## Prediction Model (Baseline)

- No heavy ML
- Prediction based on average length of recent cycles
- Can be extended later with more complex algorithms

## Security & Privacy

- Data stored locally only (no sync)
- Database encrypted with Hive AES cipher
- Manual backup/restore via JSON
- Optional PIN/biometric to unlock app

## SDK & Environment

- Dart SDK: ^3.9.2
- Flutter: Latest stable
- Platforms: Android, iOS, Web, Linux, macOS, Windows (multi-platform)
