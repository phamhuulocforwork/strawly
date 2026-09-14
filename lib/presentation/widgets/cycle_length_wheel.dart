import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../core/constants/app_constants.dart';

/// Scroll wheel for [AppConstants.minCycleLength]–[AppConstants.maxCycleLength].
class CycleLengthWheel extends StatefulWidget {
  const CycleLengthWheel({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
    required this.labelForDays,
    this.enabled = true,
  });

  final int selectedDays;
  final ValueChanged<int> onDaysChanged;
  final String Function(int days) labelForDays;
  final bool enabled;

  @override
  State<CycleLengthWheel> createState() => _CycleLengthWheelState();
}

class _CycleLengthWheelState extends State<CycleLengthWheel> {
  static const int _itemCount =
      AppConstants.maxCycleLength - AppConstants.minCycleLength + 1;

  late final WheelPickerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WheelPickerController(
      itemCount: _itemCount,
      initialIndex: _indexForDays(widget.selectedDays),
    );
  }

  @override
  void didUpdateWidget(covariant CycleLengthWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDays != widget.selectedDays) {
      _controller.setCurrent(_indexForDays(widget.selectedDays));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _indexForDays(int days) {
    return (days - AppConstants.minCycleLength).clamp(0, _itemCount - 1);
  }

  int _daysForIndex(int index) => AppConstants.minCycleLength + index;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 22, height: 1.35);
    final accent = Theme.of(context).colorScheme.primary;

    return AnimatedOpacity(
      opacity: widget.enabled ? 1 : 0.35,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !widget.enabled,
        child: SizedBox(
          width: double.infinity,
          height: 180,
          child: WheelPicker(
            controller: _controller,
            looping: false,
            enableTap: true,
            selectedIndexColor: accent,
            onIndexChanged: (index, _) {
              widget.onDaysChanged(_daysForIndex(index));
            },
            builder: (context, index) {
              final days = _daysForIndex(index);
              return Center(
                child: Text(
                  widget.labelForDays(days),
                  style: textStyle,
                ),
              );
            },
            style: WheelPickerStyle(
              itemExtent: textStyle.fontSize! * textStyle.height!,
              squeeze: 1.1,
              diameterRatio: 1.05,
              surroundingOpacity: 0.3,
              magnification: 1.15,
            ),
          ),
        ),
      ),
    );
  }
}
