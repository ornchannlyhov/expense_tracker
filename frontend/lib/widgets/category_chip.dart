import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;

  const CategoryChip({ super.key, required this.label, this.isSelected = false, this.onSelected });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label), selected: isSelected, onSelected: onSelected,
      backgroundColor: isSelected ? null : theme.chipTheme.backgroundColor,
      selectedColor: theme.chipTheme.selectedColor,
      labelStyle: TextStyle(
        color: isSelected ? theme.chipTheme.secondaryLabelStyle?.color : theme.chipTheme.labelStyle?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: theme.chipTheme.secondaryLabelStyle?.color,
      padding: theme.chipTheme.padding, shape: theme.chipTheme.shape,
      showCheckmark: true, pressElevation: 2,
    );
  }
}