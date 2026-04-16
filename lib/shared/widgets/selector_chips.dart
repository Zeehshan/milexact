import 'package:flutter/material.dart';

class SelectorChips<T> extends StatelessWidget {
  const SelectorChips({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<T> options;
  final T? selectedValue;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        // runSpacing: 8,
        children: options
            .map(
              (option) => ChoiceChip(
                label: Text(labelBuilder(option)),
                selected: option == selectedValue,
                showCheckmark: false,
                onSelected: (_) => onSelected(option),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
