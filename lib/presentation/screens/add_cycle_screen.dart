import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/cycle.dart';
import '../../l10n/app_localizations.dart';
import '../theme/bento_tokens.dart';
import '../viewmodels/cycle_viewmodel.dart';
import '../widgets/bento_tile.dart';
import '../widgets/period_range_picker.dart';

class AddCycleScreen extends ConsumerStatefulWidget {
  const AddCycleScreen({
    super.key,
    this.cycleToEdit,
    this.embeddedInSheet = false,
    this.scrollController,
    this.onSaved,
  });

  final Cycle? cycleToEdit;
  final bool embeddedInSheet;
  final ScrollController? scrollController;
  final VoidCallback? onSaved;

  @override
  ConsumerState<AddCycleScreen> createState() => _AddCycleScreenState();
}

class _AddCycleScreenState extends ConsumerState<AddCycleScreen> {
  final _formKey = GlobalKey<FormState>();
  late ShadDateTimeRange? _periodRange;
  late DateTime _startDate;
  int? _cycleLength;
  int? _periodDuration;
  String? _notes;
  PeriodRangeValidationError? _periodRangeError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.cycleToEdit != null) {
      _startDate = widget.cycleToEdit!.startDate;
      _cycleLength = widget.cycleToEdit!.cycleLength;
      _periodDuration = widget.cycleToEdit!.periodDuration;
      _notes = widget.cycleToEdit!.notes;
      _periodRange = PeriodRangeLogic.fromCycle(_startDate, _periodDuration);
    } else {
      _periodRange = PeriodRangeLogic.defaultRange();
      _applyRange(_periodRange);
    }
  }

  void _applyRange(ShadDateTimeRange? range) {
    if (range?.start != null) {
      _startDate = PeriodRangeLogic.startDateFrom(range!);
    }
    _periodDuration = range == null
        ? null
        : PeriodRangeLogic.periodDurationFrom(range);
  }

  void _onPeriodRangeChanged(ShadDateTimeRange? range) {
    setState(() {
      _periodRange = range;
      _applyRange(range);
      _periodRangeError = PeriodRangeLogic.validateError(range);
    });
  }

  bool _validatePeriodRange(AppLocalizations l10n) {
    final error = PeriodRangeLogic.validateError(_periodRange);
    setState(() => _periodRangeError = error);
    return error == null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.embeddedInSheet)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                BentoTokens.space16,
                0,
                BentoTokens.space16,
                BentoTokens.space8,
              ),
              child: Text(
                widget.cycleToEdit != null ? l10n.editCycle : l10n.addCycle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          BentoTile(
            label: l10n.cycleEntryHelp,
            variant: BentoTileVariant.primary,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: BentoTokens.onSurfaceText(context),
                ),
                const SizedBox(width: BentoTokens.space12),
                Expanded(
                  child: Text(
                    l10n.cycleEntryHelpText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: BentoTokens.space16),
          PeriodRangePicker(
            selected: _periodRange,
            onChanged: _onPeriodRangeChanged,
            errorText: _periodRangeError == null
                ? null
                : PeriodRangeLogic.localizedMessage(
                    _periodRangeError!,
                    l10n,
                  ),
          ),
          if (widget.cycleToEdit != null) ...[
            const SizedBox(height: BentoTokens.space16),
            Text(
              l10n.cycleLength,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: BentoTokens.space4),
            Text(
              l10n.totalCycleLengthOptional,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BentoTokens.mutedText(context),
              ),
            ),
            const SizedBox(height: BentoTokens.space8),
            TextFormField(
              initialValue: _cycleLength?.toString(),
              keyboardType: TextInputType.number,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: l10n.cycleLengthHint,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BentoTokens.mutedText(context),
                ),
                suffixText: l10n.daysSuffix,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _cycleLength = int.tryParse(value);
                });
              },
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final length = int.tryParse(value);
                  if (length == null) {
                    return l10n.enterValidNumber;
                  }
                  if (length < AppConstants.minCycleLength ||
                      length > AppConstants.maxCycleLength) {
                    return l10n.cycleLengthRange(
                      AppConstants.minCycleLength,
                      AppConstants.maxCycleLength,
                    );
                  }
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: BentoTokens.space16),
          Text(
            l10n.notesOptional,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: BentoTokens.space8),
          TextFormField(
            initialValue: _notes,
            maxLines: 4,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: l10n.notesHint,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BentoTokens.mutedText(context),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                _notes = value.isEmpty ? null : value;
              });
            },
          ),
          const SizedBox(height: BentoTokens.space24),
          ShadButton(
            width: double.infinity,
            onPressed: _isLoading ? null : () => _saveCycle(l10n),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    widget.cycleToEdit != null
                        ? l10n.updateCycle
                        : l10n.addCycle,
                  ),
          ),
          const SizedBox(height: BentoTokens.space16),
        ],
      ),
    );

    if (widget.embeddedInSheet) {
      return ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(BentoTokens.space16),
        children: [form],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cycleToEdit != null ? l10n.editCycle : l10n.addCycle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BentoTokens.space16),
          child: form,
        ),
      ),
    );
  }

  Future<void> _saveCycle(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate() || !_validatePeriodRange(l10n)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cycle = Cycle(
        id:
            widget.cycleToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        startDate: _startDate,
        cycleLength: _cycleLength,
        periodDuration: _periodDuration,
        notes: _notes,
        createdAt: widget.cycleToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.cycleToEdit != null) {
        await ref.read(cycleListProvider.notifier).updateCycle(cycle);
      } else {
        await ref.read(cycleListProvider.notifier).addCycle(cycle);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.cycleToEdit != null
                ? l10n.cycleUpdatedSuccess
                : l10n.cycleAddedSuccess,
          ),
          backgroundColor: BentoTokens.success,
        ),
      );

      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMessage(e.toString())),
            backgroundColor: BentoTokens.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
