import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../theme/bento_tokens.dart';
import 'cycle_length_wheel.dart';

/// User confirmed a choice ( [days] null = use app default).
class TypicalCycleLengthPickOutcome {
  const TypicalCycleLengthPickOutcome({required this.days});

  final int? days;
}

/// Picker for typical cycle length: app default or a value from [minCycleLength]
/// through [maxCycleLength] on a wheel. Returns null when cancelled.
Future<TypicalCycleLengthPickOutcome?> showTypicalCycleLengthPickerDialog(
  BuildContext context, {
  required int? current,
}) {
  return showDialog<TypicalCycleLengthPickOutcome>(
    context: context,
    builder: (context) => TypicalCycleLengthPickerDialog(current: current),
  );
}

class TypicalCycleLengthPickerDialog extends StatefulWidget {
  const TypicalCycleLengthPickerDialog({super.key, required this.current});

  final int? current;

  @override
  State<TypicalCycleLengthPickerDialog> createState() =>
      _TypicalCycleLengthPickerDialogState();
}

class _TypicalCycleLengthPickerDialogState
    extends State<TypicalCycleLengthPickerDialog> {
  late bool _useDefault;
  late int _selectedDays;

  @override
  void initState() {
    super.initState();
    _useDefault = widget.current == null;
    _selectedDays = widget.current ?? AppConstants.defaultCycleLength;
  }

  void _onSave() {
    Navigator.pop(
      context,
      TypicalCycleLengthPickOutcome(
        days: _useDefault ? null : _selectedDays,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            BentoTokens.space24,
            BentoTokens.space24,
            BentoTokens.space24,
            BentoTokens.space16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.typicalCycleLengthDialogTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: BentoTokens.space16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.typicalCycleLengthDefault(
                    AppConstants.defaultCycleLength,
                  ),
                ),
                subtitle: Text(l10n.typicalCycleLengthSubtitle),
                value: _useDefault,
                onChanged: (value) => setState(() => _useDefault = value),
              ),
              const SizedBox(height: BentoTokens.space8),
              CycleLengthWheel(
                selectedDays: _selectedDays,
                enabled: !_useDefault,
                labelForDays: l10n.typicalCycleLengthDays,
                onDaysChanged: (days) => setState(() => _selectedDays = days),
              ),
              const SizedBox(height: BentoTokens.space8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: BentoTokens.space8),
                  ShadButton(
                    onPressed: _onSave,
                    child: Text(l10n.continueButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
