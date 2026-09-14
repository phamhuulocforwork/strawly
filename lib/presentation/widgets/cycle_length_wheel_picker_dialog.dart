import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../theme/bento_tokens.dart';
import 'cycle_length_wheel.dart';

class RecordedCycleLengthPickOutcome {
  const RecordedCycleLengthPickOutcome({required this.days});

  /// Null when the user clears manual cycle length.
  final int? days;
}

Future<RecordedCycleLengthPickOutcome?> showRecordedCycleLengthPickerDialog(
  BuildContext context, {
  required int? current,
}) {
  return showDialog<RecordedCycleLengthPickOutcome>(
    context: context,
    builder: (context) => RecordedCycleLengthPickerDialog(current: current),
  );
}

class RecordedCycleLengthPickerDialog extends StatefulWidget {
  const RecordedCycleLengthPickerDialog({super.key, required this.current});

  final int? current;

  @override
  State<RecordedCycleLengthPickerDialog> createState() =>
      _RecordedCycleLengthPickerDialogState();
}

class _RecordedCycleLengthPickerDialogState
    extends State<RecordedCycleLengthPickerDialog> {
  late bool _leaveUnset;
  late int _selectedDays;

  @override
  void initState() {
    super.initState();
    _leaveUnset = widget.current == null;
    _selectedDays = widget.current ?? AppConstants.defaultCycleLength;
  }

  void _onSave() {
    Navigator.pop(
      context,
      RecordedCycleLengthPickOutcome(
        days: _leaveUnset ? null : _selectedDays,
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
              Text(l10n.cycleLength, style: theme.textTheme.titleLarge),
              const SizedBox(height: BentoTokens.space16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.cycleLengthLeaveUnset),
                subtitle: Text(l10n.totalCycleLengthOptional),
                value: _leaveUnset,
                onChanged: (value) => setState(() => _leaveUnset = value),
              ),
              const SizedBox(height: BentoTokens.space8),
              CycleLengthWheel(
                selectedDays: _selectedDays,
                enabled: !_leaveUnset,
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
