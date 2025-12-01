import 'package:boulderside_flutter/src/shared/widgets/sort_button.dart';
import 'package:flutter/material.dart';

class SortOption<T> {
  const SortOption({required this.label, required this.value});

  final String label;
  final T value;
}

class SortOptionBar<T> extends StatelessWidget {
  const SortOptionBar({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.padding = const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 10),
    this.gap = 10,
  });

  final List<SortOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Wrap(
        spacing: gap,
        children: options
            .map(
              (option) => SortButton(
                text: option.label,
                selected: selectedValue == option.value,
                onTap: () => onSelected(option.value),
              ),
            )
            .toList(),
      ),
    );
  }
}
