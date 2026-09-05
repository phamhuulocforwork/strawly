// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Strawly - Menstrual Cycle Tracker';

  @override
  String get appName => 'Strawly';

  @override
  String get homeSubtitle => 'Your private cycle dashboard';

  @override
  String get navHome => 'Home';

  @override
  String get navStats => 'Stats';

  @override
  String get navSettings => 'Settings';

  @override
  String get addCycleTooltip => 'Add cycle';

  @override
  String get loadingPrediction => 'Loading prediction';

  @override
  String get predictionError => 'Prediction error';

  @override
  String get loadingCalendar => 'Loading calendar';

  @override
  String get calendarError => 'Calendar error';

  @override
  String get avgCycle => 'Avg cycle';

  @override
  String get loadingAvgCycle => 'Loading average cycle';

  @override
  String get regularity => 'Regularity';

  @override
  String get loadingRegularity => 'Loading regularity';

  @override
  String get recentCycles => 'Recent cycles';

  @override
  String get ongoing => 'Ongoing';

  @override
  String lengthDays(int count) {
    return 'Length: $count days';
  }

  @override
  String avgCycleDays(String value) {
    return '$value days';
  }

  @override
  String get predictionUnavailable => 'Prediction unavailable';

  @override
  String get noPredictionYet => 'No prediction yet';

  @override
  String get addMoreCyclesForPrediction =>
      'Add more cycles to unlock predictions.';

  @override
  String get nextPeriodPrediction => 'Next period prediction';

  @override
  String get nextPeriod => 'Next period';

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get expectedToday => 'Expected today';

  @override
  String daysOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days overdue',
      one: '1 day overdue',
    );
    return '$_temp0';
  }

  @override
  String get cycleCalendar => 'Cycle calendar';

  @override
  String get legendPeriod => 'Period';

  @override
  String get legendFertile => 'Fertile';

  @override
  String get legendPredicted => 'Predicted';

  @override
  String get periodDateRange => 'Period date range';

  @override
  String get periodDates => 'Period dates';

  @override
  String get periodDatesHint =>
      'Tap the first bleeding day, then the last. Duration is calculated for you.';

  @override
  String daysSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days selected',
      one: '1 day selected',
    );
    return '$_temp0';
  }

  @override
  String dateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get periodSelectFirstDay => 'Select the first day of your period.';

  @override
  String get periodSelectLastDay => 'Select the last day of your period.';

  @override
  String get periodOutOfRange =>
      'Selected dates must be within the allowed range.';

  @override
  String periodDurationRange(int min, int max) {
    return 'Period should be between $min–$max days.';
  }

  @override
  String get addCycle => 'Add cycle';

  @override
  String get editCycle => 'Edit cycle';

  @override
  String get cycleEntryHelp => 'Cycle entry help';

  @override
  String get cycleEntryHelpText =>
      'Select your period on the calendar below. Cycle length is calculated when you add the next cycle.';

  @override
  String get cycleLength => 'Cycle length';

  @override
  String get totalCycleLengthOptional => 'Total cycle length (optional)';

  @override
  String get cycleLengthHint => 'e.g., 28';

  @override
  String get daysSuffix => 'days';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String cycleLengthRange(int short, int long) {
    return '$short - $long days';
  }

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get notesHint => 'Add notes about symptoms, mood, etc.';

  @override
  String get updateCycle => 'Update cycle';

  @override
  String get cycleUpdatedSuccess => 'Cycle updated successfully';

  @override
  String get cycleAddedSuccess => 'Cycle added successfully';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeSubtitle => 'Use dark theme for the app';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Choose app language and date format';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get dataManagement => 'Data management';

  @override
  String get exportData => 'Export data';

  @override
  String get exportDataSubtitle => 'Backup your cycle data as JSON';

  @override
  String get importData => 'Import data';

  @override
  String get importDataSubtitle => 'Restore from backup file';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String get deleteAllDataSubtitle => 'Permanently delete all cycles';

  @override
  String get about => 'About';

  @override
  String get aboutStrawly => 'About Strawly';

  @override
  String get version => 'Version';

  @override
  String get versionNumber => '1.0.0';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacySubtitle => 'All data stored locally on device';

  @override
  String get security => 'Security';

  @override
  String get securitySubtitle => 'Data encrypted with AES-256';

  @override
  String get brandingSubtitle => 'Your private menstrual cycle tracker';

  @override
  String get strawlyBranding => 'Strawly branding';

  @override
  String get dataExported => 'Data exported to clipboard';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get importDataTitle => 'Import data';

  @override
  String get importDataConfirm =>
      'This will replace all existing data. Make sure you have a backup first.\n\nPaste your backup JSON in the next step.';

  @override
  String get cancel => 'Cancel';

  @override
  String get continueButton => 'Continue';

  @override
  String get pasteBackupTitle => 'Paste backup data';

  @override
  String get pasteBackupHint => 'Paste your JSON backup here';

  @override
  String get importButton => 'Import';

  @override
  String importedCycles(int count) {
    return 'Successfully imported $count cycles';
  }

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get deleteAllDataTitle => 'Delete all data?';

  @override
  String get deleteAllDataConfirm =>
      'This will permanently delete all your cycle data. This action cannot be undone.\n\nMake sure you have exported your data first if you want to keep it.';

  @override
  String get deleteAllButton => 'Delete all';

  @override
  String get allDataDeleted => 'All data deleted';

  @override
  String deleteFailed(String error) {
    return 'Delete failed: $error';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get statisticsError => 'Statistics error';

  @override
  String get noStatisticsYet => 'No statistics yet';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get addCyclesForInsights =>
      'Add cycles to unlock insights and trends.';

  @override
  String get totalCycles => 'Total cycles';

  @override
  String get complete => 'Complete';

  @override
  String get stdDev => 'Std dev';

  @override
  String get cycleLengthHistory => 'Cycle length history';

  @override
  String get notEnoughChartData => 'Not enough data to display chart.';

  @override
  String lastNCycles(int count) {
    return 'Last $count cycles';
  }

  @override
  String get regularityScore => 'Regularity score';

  @override
  String get deviationFromAverage => 'Deviation from average';

  @override
  String get averageShort => 'Avg';

  @override
  String get avgPeriod => 'Avg period';

  @override
  String get shortestCycle => 'Shortest cycle';

  @override
  String get longestCycle => 'Longest cycle';

  @override
  String get currentCycleDay => 'Current cycle day';

  @override
  String currentCycleDayValue(int day) {
    return 'Day $day';
  }

  @override
  String get shortestLongest => 'Shortest / Longest';

  @override
  String predictionReadyStatus(int count) {
    return 'Enough data to predict: $count cycles';
  }

  @override
  String get cyclesRegular => 'Your cycles are regular.';

  @override
  String get cyclesVariation => 'Your cycles show some variation.';

  @override
  String get additionalInformation => 'Additional information';

  @override
  String get completeCycles => 'Complete cycles';

  @override
  String get standardDeviation => 'Standard deviation';

  @override
  String get nextExpected => 'Next expected';

  @override
  String daysUnit(String count) {
    return '$count days';
  }

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get predictedNextPeriod => 'Next expected period';

  @override
  String get daysLabel => 'days';

  @override
  String get logPeriodToday => 'Log period today';

  @override
  String get loggedPeriodToday => 'Logged today';

  @override
  String get phasePeriod => 'Period';

  @override
  String get phaseFollicular => 'Follicular';

  @override
  String get phaseFertile => 'Fertile window';

  @override
  String get phaseLuteal => 'Luteal';

  @override
  String get periodLoggedSuccess => 'Period logged — prediction updated';
}
