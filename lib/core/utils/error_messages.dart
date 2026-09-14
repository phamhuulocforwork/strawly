import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../l10n/app_localizations.dart';

/// Maps technical exceptions to short, friendly, localized messages.
class ErrorMessages {
  ErrorMessages._();

  static String friendly(Object error, AppLocalizations l10n) {
    debugPrint('Strawly error: $error');
    if (error is HiveError || error is ArgumentError) {
      return l10n.errorStorage;
    }
    if (error is FormatException || error is TypeError) {
      return l10n.errorInvalidData;
    }
    return l10n.somethingWentWrong;
  }
}
