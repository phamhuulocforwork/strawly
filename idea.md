# Flutter App for Menstrual Cycle Tracking (Offline-First)

## Objectives

Build a personal Flutter application that runs completely offline, allowing users to:

Record menstrual cycle history.

Predict the next period based on historical data.

Display calendar, statistical charts, and basic health information.

Absolute security (data stored internally with encryption).

The app is not commercial or cloud-sync oriented.

## Software Architecture

Clean Architecture + MVVM (or Riverpod/BLoC)

```txt
lib/
 ├── data/          ← Storage, repository, model, local DB
 ├── domain/        ← Business logic (use cases, entities)
 ├── presentation/  ← UI, view model, state management
 └── core/          ← Constants, helpers, theme, utils, dependency injection
```

## Data Flow

```txt
UI → ViewModel → UseCase → Repository → Local DataSource → Hive/SQLite
↑                                                   ↓
└───────────── display results (cycles, predictions, statistics)
```

## Main Business Logic

Enter new cycle
→ Save CycleModel (start date, length, notes)

Calculate average cycle length
→ Based on historical data (Moving Average / Weighted Average)

Predict next cycle
→ nextStartDate = lastStartDate + avgLength

Statistics
→ Trend charts, standard deviation, regular/irregular cycles

Data security
→ Store with Hive + AES encryption (HiveAesCipher)

## Prediction Model (Baseline)

No heavy ML.
Prediction based on average length of recent cycles:

## Security & Privacy

Data stored locally only (no sync).

Database encrypted with Hive AES cipher.

Allow manual backup/restore via JSON.

Option to add PIN or biometrics to unlock app.

## Proposed UI/UX

Soft pastel tone, conveying trust and privacy.

Screens:

Home: calendar + prediction info

Enter new cycle

Statistics (charts, regularity ratio)

Settings (security, data export)
