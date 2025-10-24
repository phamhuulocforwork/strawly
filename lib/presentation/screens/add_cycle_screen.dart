import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/cycle.dart';
import '../viewmodels/cycle_viewmodel.dart';

class AddCycleScreen extends ConsumerStatefulWidget {
  final Cycle? cycleToEdit;

  const AddCycleScreen({super.key, this.cycleToEdit});

  @override
  ConsumerState<AddCycleScreen> createState() => _AddCycleScreenState();
}

class _AddCycleScreenState extends ConsumerState<AddCycleScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  int? _cycleLength;
  int? _periodDuration;
  String? _notes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.cycleToEdit != null) {
      _startDate = widget.cycleToEdit!.startDate;
      _cycleLength = widget.cycleToEdit!.cycleLength;
      _periodDuration = widget.cycleToEdit!.periodDuration;
      _notes = widget.cycleToEdit!.notes;
    } else {
      _startDate = DateTime.now();
      _periodDuration = AppConstants.periodDuration;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cycleToEdit != null ? 'Edit Cycle' : 'Add Cycle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShadCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Record the start date of your period. The cycle length will be calculated automatically when you add the next cycle.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Start Date',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ShadCard(
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Period Start Date'),
                    subtitle: Text(DateTimeUtils.formatDate(_startDate)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Period Duration (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ShadCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How many days did your period last?',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _periodDuration?.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Days',
                                  hintText: 'e.g., 5',
                                  border: OutlineInputBorder(),
                                  suffixText: 'days',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _periodDuration = int.tryParse(value);
                                  });
                                },
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final duration = int.tryParse(value);
                                    if (duration == null) {
                                      return 'Please enter a valid number';
                                    }
                                    if (duration < 1 || duration > 10) {
                                      return 'Duration should be between 1-10 days';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (widget.cycleToEdit != null) ...[
                  Text(
                    'Cycle Length',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ShadCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total cycle length (optional)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _cycleLength?.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Cycle Length',
                                    hintText: 'e.g., 28',
                                    border: OutlineInputBorder(),
                                    suffixText: 'days',
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
                                        return 'Please enter a valid number';
                                      }
                                      if (length <
                                              AppConstants.minCycleLength ||
                                          length >
                                              AppConstants.maxCycleLength) {
                                        return 'Length should be between ${AppConstants.minCycleLength}-${AppConstants.maxCycleLength} days';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Text(
                  'Notes (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ShadCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      initialValue: _notes,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Add any notes about symptoms, mood, etc.',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _notes = value.isEmpty ? null : value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCycle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            widget.cycleToEdit != null
                                ? 'Update Cycle'
                                : 'Add Cycle',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveCycle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.cycleToEdit != null
                  ? 'Cycle updated successfully'
                  : 'Cycle added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
