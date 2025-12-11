import 'package:flutter/material.dart';

class SegmentOption<T> {
  const SegmentOption({required this.label, required this.value});

  final String label;
  final T value;
}

class SegmentedToggleBar<T> extends StatelessWidget {
  const SegmentedToggleBar({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.backgroundColor = const Color(0xAA1E2129),
    this.selectedColor = const Color(0xFFFF3278),
    this.unselectedColor = Colors.white70,
    this.inactiveFillColor = const Color(0x33242734),
    this.textStyle = const TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
    ),
    this.padding = const EdgeInsets.all(6),
    this.chipPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.borderRadius = 24,
    this.chipRadius = 18,
    this.spacing = 6,
  });

  final List<SegmentOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final Color inactiveFillColor;
  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry chipPadding;
  final double borderRadius;
  final double chipRadius;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            _SegmentChip<T>(
              option: options[i],
              isSelected: options[i].value == selectedValue,
              onTap: () => onChanged(options[i].value),
              selectedColor: selectedColor,
              inactiveFillColor: inactiveFillColor,
              unselectedColor: unselectedColor,
              textStyle: textStyle,
              padding: chipPadding,
              borderRadius: chipRadius,
            ),
            if (i != options.length - 1) SizedBox(width: spacing),
          ],
        ],
      ),
    );
  }
}

class _SegmentChip<T> extends StatelessWidget {
  const _SegmentChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.inactiveFillColor,
    required this.unselectedColor,
    required this.textStyle,
    required this.padding,
    required this.borderRadius,
  });

  final SegmentOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  final Color selectedColor;
  final Color inactiveFillColor;
  final Color unselectedColor;
  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : inactiveFillColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Text(
          option.label,
          style: textStyle.copyWith(
            color: isSelected ? Colors.white : unselectedColor,
          ),
        ),
      ),
    );
  }
}
