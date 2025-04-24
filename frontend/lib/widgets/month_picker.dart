import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthPicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime selectedMonth) onMonthSelected;

  const MonthPicker({ super.key, required this.initialDate, required this.onMonthSelected });

  @override
  _MonthPickerState createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState(); _selectedMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
  }

  void _changeMonth(int monthsToAdd) {
    setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + monthsToAdd, 1));
    widget.onMonthSelected(_selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton(icon: Icon(Icons.chevron_left, color: theme.colorScheme.secondary), onPressed: () => _changeMonth(-1), tooltip: 'Previous Month'),
        Text(DateFormat('MMMM yyyy').format(_selectedMonth), style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
        IconButton(icon: Icon(Icons.chevron_right, color: theme.colorScheme.secondary), onPressed: () => _changeMonth(1), tooltip: 'Next Month'),
      ],);
  }
}