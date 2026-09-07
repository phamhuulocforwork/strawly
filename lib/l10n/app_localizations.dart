import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Strawly - Menstrual Cycle Tracker'**
  String get appTitle;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Strawly'**
  String get appName;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your private cycle dashboard'**
  String get homeSubtitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @addCycleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add cycle'**
  String get addCycleTooltip;

  /// No description provided for @loadingPrediction.
  ///
  /// In en, this message translates to:
  /// **'Loading prediction'**
  String get loadingPrediction;

  /// No description provided for @predictionError.
  ///
  /// In en, this message translates to:
  /// **'Prediction error'**
  String get predictionError;

  /// No description provided for @loadingCalendar.
  ///
  /// In en, this message translates to:
  /// **'Loading calendar'**
  String get loadingCalendar;

  /// No description provided for @calendarError.
  ///
  /// In en, this message translates to:
  /// **'Calendar error'**
  String get calendarError;

  /// No description provided for @avgCycle.
  ///
  /// In en, this message translates to:
  /// **'Avg cycle'**
  String get avgCycle;

  /// No description provided for @loadingAvgCycle.
  ///
  /// In en, this message translates to:
  /// **'Loading average cycle'**
  String get loadingAvgCycle;

  /// No description provided for @regularity.
  ///
  /// In en, this message translates to:
  /// **'Regularity'**
  String get regularity;

  /// No description provided for @loadingRegularity.
  ///
  /// In en, this message translates to:
  /// **'Loading regularity'**
  String get loadingRegularity;

  /// No description provided for @recentCycles.
  ///
  /// In en, this message translates to:
  /// **'Recent cycles'**
  String get recentCycles;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @lengthDays.
  ///
  /// In en, this message translates to:
  /// **'Length: {count} days'**
  String lengthDays(int count);

  /// No description provided for @avgCycleDays.
  ///
  /// In en, this message translates to:
  /// **'{value} days'**
  String avgCycleDays(String value);

  /// No description provided for @predictionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Prediction unavailable'**
  String get predictionUnavailable;

  /// No description provided for @noPredictionYet.
  ///
  /// In en, this message translates to:
  /// **'No prediction yet'**
  String get noPredictionYet;

  /// No description provided for @addMoreCyclesForPrediction.
  ///
  /// In en, this message translates to:
  /// **'Add more cycles to unlock predictions.'**
  String get addMoreCyclesForPrediction;

  /// No description provided for @nextPeriodPrediction.
  ///
  /// In en, this message translates to:
  /// **'Next period prediction'**
  String get nextPeriodPrediction;

  /// No description provided for @nextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get nextPeriod;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left} other{{count} days left}}'**
  String daysLeft(int count);

  /// No description provided for @expectedToday.
  ///
  /// In en, this message translates to:
  /// **'Expected today'**
  String get expectedToday;

  /// No description provided for @daysOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day overdue} other{{count} days overdue}}'**
  String daysOverdue(int count);

  /// No description provided for @cycleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Cycle calendar'**
  String get cycleCalendar;

  /// No description provided for @legendPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get legendPeriod;

  /// No description provided for @legendFertile.
  ///
  /// In en, this message translates to:
  /// **'Fertile'**
  String get legendFertile;

  /// No description provided for @legendPredicted.
  ///
  /// In en, this message translates to:
  /// **'Predicted'**
  String get legendPredicted;

  /// No description provided for @periodDateRange.
  ///
  /// In en, this message translates to:
  /// **'Period date range'**
  String get periodDateRange;

  /// No description provided for @periodDates.
  ///
  /// In en, this message translates to:
  /// **'Period dates'**
  String get periodDates;

  /// No description provided for @periodDatesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the first bleeding day, then the last. Duration is calculated for you.'**
  String get periodDatesHint;

  /// No description provided for @daysSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day selected} other{{count} days selected}}'**
  String daysSelected(int count);

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String dateRange(String start, String end);

  /// No description provided for @periodSelectFirstDay.
  ///
  /// In en, this message translates to:
  /// **'Select the first day of your period.'**
  String get periodSelectFirstDay;

  /// No description provided for @periodSelectLastDay.
  ///
  /// In en, this message translates to:
  /// **'Select the last day of your period.'**
  String get periodSelectLastDay;

  /// No description provided for @periodOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Selected dates must be within the allowed range.'**
  String get periodOutOfRange;

  /// No description provided for @periodDurationRange.
  ///
  /// In en, this message translates to:
  /// **'Period should be between {min}–{max} days.'**
  String periodDurationRange(int min, int max);

  /// No description provided for @addCycle.
  ///
  /// In en, this message translates to:
  /// **'Add cycle'**
  String get addCycle;

  /// No description provided for @editCycle.
  ///
  /// In en, this message translates to:
  /// **'Edit cycle'**
  String get editCycle;

  /// No description provided for @cycleEntryHelp.
  ///
  /// In en, this message translates to:
  /// **'Cycle entry help'**
  String get cycleEntryHelp;

  /// No description provided for @cycleEntryHelpText.
  ///
  /// In en, this message translates to:
  /// **'Select your period on the calendar below. Cycle length is calculated when you add the next cycle.'**
  String get cycleEntryHelpText;

  /// No description provided for @cycleLength.
  ///
  /// In en, this message translates to:
  /// **'Cycle length'**
  String get cycleLength;

  /// No description provided for @totalCycleLengthOptional.
  ///
  /// In en, this message translates to:
  /// **'Total cycle length (optional)'**
  String get totalCycleLengthOptional;

  /// No description provided for @cycleLengthHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 28'**
  String get cycleLengthHint;

  /// No description provided for @daysSuffix.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysSuffix;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @cycleLengthRange.
  ///
  /// In en, this message translates to:
  /// **'{short} - {long} days'**
  String cycleLengthRange(int short, int long);

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes about symptoms, mood, etc.'**
  String get notesHint;

  /// No description provided for @updateCycle.
  ///
  /// In en, this message translates to:
  /// **'Update cycle'**
  String get updateCycle;

  /// No description provided for @cycleUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cycle updated successfully'**
  String get cycleUpdatedSuccess;

  /// No description provided for @cycleAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cycle added successfully'**
  String get cycleAddedSuccess;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme for the app'**
  String get darkModeSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose app language and date format'**
  String get languageSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get dataManagement;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup your cycle data as JSON'**
  String get exportDataSubtitle;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get importData;

  /// No description provided for @importDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup file'**
  String get importDataSubtitle;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all cycles'**
  String get deleteAllDataSubtitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutStrawly.
  ///
  /// In en, this message translates to:
  /// **'About Strawly'**
  String get aboutStrawly;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @versionNumber.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get versionNumber;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'All data stored locally on device'**
  String get privacySubtitle;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @securitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data encrypted with AES-256'**
  String get securitySubtitle;

  /// No description provided for @brandingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your private menstrual cycle tracker'**
  String get brandingSubtitle;

  /// No description provided for @strawlyBranding.
  ///
  /// In en, this message translates to:
  /// **'Strawly branding'**
  String get strawlyBranding;

  /// No description provided for @dataExported.
  ///
  /// In en, this message translates to:
  /// **'Data exported to clipboard'**
  String get dataExported;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @importDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get importDataTitle;

  /// No description provided for @importDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will replace all existing data. Make sure you have a backup first.\n\nPaste your backup JSON in the next step.'**
  String get importDataConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @pasteBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste backup data'**
  String get pasteBackupTitle;

  /// No description provided for @pasteBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your JSON backup here'**
  String get pasteBackupHint;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// No description provided for @importedCycles.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported {count} cycles'**
  String importedCycles(int count);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @deleteAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllDataTitle;

  /// No description provided for @deleteAllDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your cycle data. This action cannot be undone.\n\nMake sure you have exported your data first if you want to keep it.'**
  String get deleteAllDataConfirm;

  /// No description provided for @deleteAllButton.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAllButton;

  /// No description provided for @allDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All data deleted'**
  String get allDataDeleted;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String deleteFailed(String error);

  /// No description provided for @deleteCycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this cycle?'**
  String get deleteCycleTitle;

  /// No description provided for @deleteCycleConfirm.
  ///
  /// In en, this message translates to:
  /// **'The cycle starting {date} will be permanently deleted.'**
  String deleteCycleConfirm(String date);

  /// No description provided for @deleteCycleButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteCycleButton;

  /// No description provided for @cycleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Cycle deleted'**
  String get cycleDeleted;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @statisticsError.
  ///
  /// In en, this message translates to:
  /// **'Statistics error'**
  String get statisticsError;

  /// No description provided for @noStatisticsYet.
  ///
  /// In en, this message translates to:
  /// **'No statistics yet'**
  String get noStatisticsYet;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @addCyclesForInsights.
  ///
  /// In en, this message translates to:
  /// **'Add cycles to unlock insights and trends.'**
  String get addCyclesForInsights;

  /// No description provided for @totalCycles.
  ///
  /// In en, this message translates to:
  /// **'Total cycles'**
  String get totalCycles;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @stdDev.
  ///
  /// In en, this message translates to:
  /// **'Std dev'**
  String get stdDev;

  /// No description provided for @cycleLengthHistory.
  ///
  /// In en, this message translates to:
  /// **'Cycle length history'**
  String get cycleLengthHistory;

  /// No description provided for @notEnoughChartData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to display chart.'**
  String get notEnoughChartData;

  /// No description provided for @lastNCycles.
  ///
  /// In en, this message translates to:
  /// **'Last {count} cycles'**
  String lastNCycles(int count);

  /// No description provided for @regularityScore.
  ///
  /// In en, this message translates to:
  /// **'Regularity score'**
  String get regularityScore;

  /// No description provided for @deviationFromAverage.
  ///
  /// In en, this message translates to:
  /// **'Deviation from average'**
  String get deviationFromAverage;

  /// No description provided for @averageShort.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get averageShort;

  /// No description provided for @avgPeriod.
  ///
  /// In en, this message translates to:
  /// **'Avg period'**
  String get avgPeriod;

  /// No description provided for @shortestCycle.
  ///
  /// In en, this message translates to:
  /// **'Shortest cycle'**
  String get shortestCycle;

  /// No description provided for @longestCycle.
  ///
  /// In en, this message translates to:
  /// **'Longest cycle'**
  String get longestCycle;

  /// No description provided for @currentCycleDay.
  ///
  /// In en, this message translates to:
  /// **'Current cycle day'**
  String get currentCycleDay;

  /// No description provided for @currentCycleDayValue.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String currentCycleDayValue(int day);

  /// No description provided for @shortestLongest.
  ///
  /// In en, this message translates to:
  /// **'Shortest / Longest'**
  String get shortestLongest;

  /// No description provided for @predictionReadyStatus.
  ///
  /// In en, this message translates to:
  /// **'Enough data to predict: {count} cycles'**
  String predictionReadyStatus(int count);

  /// No description provided for @cyclesRegular.
  ///
  /// In en, this message translates to:
  /// **'Your cycles are regular.'**
  String get cyclesRegular;

  /// No description provided for @cyclesVariation.
  ///
  /// In en, this message translates to:
  /// **'Your cycles show some variation.'**
  String get cyclesVariation;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get additionalInformation;

  /// No description provided for @completeCycles.
  ///
  /// In en, this message translates to:
  /// **'Complete cycles'**
  String get completeCycles;

  /// No description provided for @standardDeviation.
  ///
  /// In en, this message translates to:
  /// **'Standard deviation'**
  String get standardDeviation;

  /// No description provided for @nextExpected.
  ///
  /// In en, this message translates to:
  /// **'Next expected'**
  String get nextExpected;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysUnit(String count);

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @predictedNextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next expected period'**
  String get predictedNextPeriod;

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysLabel;

  /// No description provided for @logPeriodToday.
  ///
  /// In en, this message translates to:
  /// **'Log period today'**
  String get logPeriodToday;

  /// No description provided for @loggedPeriodToday.
  ///
  /// In en, this message translates to:
  /// **'Logged today'**
  String get loggedPeriodToday;

  /// No description provided for @phasePeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get phasePeriod;

  /// No description provided for @phaseFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular'**
  String get phaseFollicular;

  /// No description provided for @phaseFertile.
  ///
  /// In en, this message translates to:
  /// **'Fertile window'**
  String get phaseFertile;

  /// No description provided for @phaseLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal'**
  String get phaseLuteal;

  /// No description provided for @periodLoggedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Period logged — prediction updated'**
  String get periodLoggedSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
