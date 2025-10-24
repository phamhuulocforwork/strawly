# UI/UX Design & Theme System

## Design Philosophy

### Core Principles

1. **Soft & Welcoming**: Pastel color palette creates calm, private atmosphere
2. **Privacy-Conscious**: Discreet UI that doesn't reveal sensitive info at a glance
3. **Accessibility**: Clear contrast, readable fonts, touch-friendly sizes
4. **Minimalist**: Clean interface, focus on essential information
5. **Responsive**: Works across all screen sizes and orientations

## Theme System

### Architecture

**Location**: `/lib/core/theme/app_theme.dart`

Uses **shadcn_ui** Flutter port for consistent, accessible components.

### Color Scheme

#### Light Theme

```dart
static const Color primaryLight = Color(0xFFF4A6B5);    // Soft pink
static const Color secondaryLight = Color(0xFFB5E2F4);  // Soft blue
static const Color accentLight = Color(0xFFE8D4F2);     // Soft lavender
static const Color background = Color(0xFFFFFBF7);      // Warm white
static const Color foreground = Color(0xFF2D2D2D);      // Dark gray
```

**Color Psychology**:

- **Pink**: Associated with femininity, care, health
- **Blue**: Trust, calm, stability
- **Lavender**: Gentle, soothing, peaceful
- **Warm white**: Clean, soft, welcoming

#### Dark Theme

```dart
static const Color primaryDark = Color(0xFFD97B8F);     // Deeper pink
static const Color secondaryDark = Color(0xFF7BB8D9);   // Deeper blue
static const Color accentDark = Color(0xFFC5A8D9);      // Deeper lavender
static const Color background = Color(0xFF1A1A1A);      // Dark gray
static const Color foreground = Color(0xFFE8E8E8);      // Light gray
```

### Theme Configuration

#### ShadcnUI Theme

```dart
static ShadThemeData lightTheme() {
  return ShadThemeData(
    brightness: Brightness.light,
    colorScheme: const ShadSlateColorScheme.light(
      primary: primaryLight,
      secondary: secondaryLight,
      background: Color(0xFFFFFBF7),
      foreground: Color(0xFF2D2D2D),
    ),
    radius: BorderRadius.circular(12), // Rounded corners throughout
  );
}
```

#### Material Theme Integration

```dart
static ThemeData getMaterialTheme(ShadThemeData shadTheme) {
  return ThemeData(
    fontFamily: shadTheme.textTheme.family,
    colorScheme: ColorScheme(
      brightness: shadTheme.brightness,
      primary: shadTheme.colorScheme.primary,
      // ... maps shadcn colors to Material
    ),
  );
}
```

### Theme Management

**Location**: `/lib/presentation/viewmodels/theme_viewmodel.dart`

```dart
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    // Save to Hive for persistence
  }
}
```

**Features**:

- System theme following (default)
- Manual light/dark override
- Persisted across app restarts
- Smooth transitions

## Screen Structure

### 1. Home Screen

**Location**: `/lib/presentation/screens/home_screen.dart`

**Layout**:

```
AppBar (minimal)
├─ Title: "Strawly"
└─ Settings icon

Body
├─ PredictionCardWidget
│  ├─ Days until next period
│  ├─ Predicted date
│  └─ Regularity status
│
├─ CycleCalendarWidget
│  ├─ Month view
│  ├─ Period days (highlighted)
│  ├─ Fertile window (subtle)
│  └─ Predicted dates (dashed)
│
└─ FloatingActionButton (+)
   └─ Add new cycle
```

### 2. Add Cycle Screen

**Location**: `/lib/presentation/screens/add_cycle_screen.dart`

**Form Elements**:

- Date picker (start date)
- Number input (cycle length)
- Number input (period duration)
- Text area (notes)
- Save/Cancel buttons

**Validation**:

- Start date required
- No duplicate cycles for same date
- Reasonable range checks (e.g., 1-50 days)

### 3. Statistics Screen

**Location**: `/lib/presentation/screens/statistics_screen.dart`

**Sections**:

```
Overview Cards
├─ Average cycle length
├─ Regularity score
└─ Total cycles tracked

Charts
├─ Cycle length trend (line chart)
├─ Period duration history
└─ Regularity over time

Insights
├─ Regular/irregular status
├─ Standard deviation
└─ Recommendations
```

### 4. Settings Screen

**Location**: `/lib/presentation/screens/settings_screen.dart`

**Options**:

```
Appearance
├─ Theme mode (System/Light/Dark)
└─ Color accent (future)

Security
├─ Enable PIN lock (planned)
├─ Enable biometric (planned)
└─ Auto-lock timeout (planned)

Data
├─ Export data (JSON)
├─ Import data (planned)
├─ Clear all data
└─ About app
```

## Custom Widgets

### CycleCalendarWidget

**Location**: `/lib/presentation/widgets/cycle_calendar_widget.dart`

**Features**:

- Month view with scrolling
- Color-coded days:
  - **Primary color**: Period days
  - **Secondary color**: Fertile window
  - **Accent color**: Predicted period
- Touch interaction for day details
- Smooth month transitions

**Implementation Highlights**:

```dart
enum _CycleType { none, period, fertile, predicted }

Color _getDayColor(_CycleType type) {
  switch (type) {
    case _CycleType.period:
      return theme.colorScheme.primary;
    case _CycleType.fertile:
      return theme.colorScheme.secondary.withOpacity(0.3);
    case _CycleType.predicted:
      return theme.colorScheme.accent.withOpacity(0.5);
    default:
      return Colors.transparent;
  }
}
```

### PredictionCardWidget

**Location**: `/lib/presentation/widgets/prediction_card_widget.dart`

**Design**:

- Prominent card at top of home screen
- Large number for days until period
- Color changes based on proximity:
  - Green: >7 days away
  - Yellow: 3-7 days away
  - Red: <3 days or overdue

## Typography

Uses shadcn_ui default font family (system-specific):

- **iOS**: SF Pro
- **Android**: Roboto
- **Web**: System fonts

**Text Styles**:

- Headings: Bold, larger size
- Body: Regular weight, comfortable reading size
- Captions: Smaller, subtle color
- Numbers: Tabular figures for alignment

## Iconography

**Library**: `lucide_icons_flutter ^3.0.0`

**Icon Usage**:

- Consistent style throughout
- Clear, recognizable symbols
- Appropriate size (24dp standard)
- Colored to match theme

**Common Icons**:

- Calendar: `LucideIcons.calendar`
- Add: `LucideIcons.plus`
- Settings: `LucideIcons.settings`
- Chart: `LucideIcons.trendingUp`
- Lock: `LucideIcons.lock`

## Spacing & Layout

**Design System**:

- Base unit: 8px
- Small spacing: 8px
- Medium spacing: 16px
- Large spacing: 24px
- Extra large: 32px

**Border Radius**: 12px (consistent throughout)

## Animations & Transitions

### Page Transitions

- Material page route (platform-specific)
- Smooth, natural motion

### State Changes

- Fade transitions for loading states
- Slide transitions for list updates
- Scale transitions for floating action button

### Calendar Navigation

- Horizontal swipe between months
- Smooth scroll with momentum

## Responsive Design

### Breakpoints

- **Mobile**: < 600px (default design)
- **Tablet**: 600-900px (wider calendar)
- **Desktop**: > 900px (multi-column layout)

### Adaptations

- Calendar scales to available width
- Cards stack on mobile, grid on tablet+
- Navigation drawer on larger screens

## Accessibility

### Features

- Semantic labels for screen readers
- Sufficient color contrast (WCAG AA)
- Touch targets ≥ 48x48 dp
- Keyboard navigation support (web/desktop)
- Focus indicators
- Error messages clearly visible

### Color Contrast Ratios

- Text on background: >4.5:1
- Interactive elements: >3:1
- Essential graphics: >3:1

## UI State Management

**Pattern**: Riverpod StateNotifier

```dart
class CycleListState {
  final bool isLoading;
  final List<Cycle> cycles;
  final String? error;
}
```

**UI States**:

1. **Loading**: Shimmer/skeleton screens
2. **Loaded**: Display data
3. **Empty**: Friendly empty state with CTA
4. **Error**: Clear error message with retry

## Best Practices

### Do's

✅ Use theme colors consistently
✅ Maintain 12px border radius
✅ Follow 8px spacing grid
✅ Use shadcn_ui components
✅ Test both light and dark themes
✅ Consider accessibility

### Don'ts

❌ Hardcode colors
❌ Mix different design systems
❌ Use tiny touch targets
❌ Ignore loading states
❌ Overcomplicate UI
❌ Show sensitive info in previews

## Future Enhancements

Planned UI improvements:

1. **Custom themes**: User-selectable color schemes
2. **Widgets**: Home screen widgets (Android/iOS)
3. **Animations**: More delightful micro-interactions
4. **Onboarding**: First-time user tutorial
5. **Insights**: AI-generated health insights
6. **Charts**: More visualization options
