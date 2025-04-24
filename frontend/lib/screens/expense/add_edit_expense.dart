// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import '../../utils/constants.dart';

class AddEditExpenseScreen extends StatefulWidget {
  static const routeName = addEditExpenseRoute;
  final Expense? expenseToEdit;

  const AddEditExpenseScreen({super.key, this.expenseToEdit});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isEditMode = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.expenseToEdit != null;
    _amountController = TextEditingController(
        text:
            _isEditMode ? widget.expenseToEdit!.amount.toStringAsFixed(2) : '');
    _notesController = TextEditingController(
        text: _isEditMode ? widget.expenseToEdit!.notes : '');
    _selectedCategory = _isEditMode
        ? widget.expenseToEdit!.category
        : kDefaultExpenseCategories.first;
    _selectedDate = _isEditMode ? widget.expenseToEdit!.date : DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogTheme: DialogThemeData(
                backgroundColor: Theme.of(context).colorScheme.surface),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showErrorSnackbar('Please select a category');
      return;
    }
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    final expenseService = Provider.of<ExpenseService>(context, listen: false);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();
    final expenseData = Expense(
      id: _isEditMode ? widget.expenseToEdit!.id : null,
      userId: 0,
      amount: amount,
      category: _selectedCategory!,
      date: _selectedDate,
      notes: notes.isEmpty ? null : notes,
    );

    if (_isEditMode) {
      expenseService.updateExpenseOptimistic(expenseData);
    } else {
      expenseService.addExpenseOptimistic(expenseData);
    }

    bool success = _isEditMode
        ? await expenseService.updateExpense(expenseData)
        : await expenseService.addExpense(expenseData);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else if (expenseService.errorMessage != null) {
      if (_isEditMode && widget.expenseToEdit != null) {
        expenseService.updateExpenseOptimistic(widget.expenseToEdit!);
      } else {
        expenseService.removeExpenseOptimistic(expenseData.id ?? 0);
      }
      _showErrorSnackbar(expenseService.errorMessage!);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    if (!_isEditMode || widget.expenseToEdit?.id == null) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete Expense?',
          style: Theme.of(ctx).textTheme.titleLarge,
        ),
        content: Text(
          'This will permanently delete the expense for ${widget.expenseToEdit!.category}.',
          style: Theme.of(ctx).textTheme.bodyMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.onSurface,
            ),
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _isSubmitting = true);
      final expenseService =
          Provider.of<ExpenseService>(context, listen: false);
      expenseService.removeExpenseOptimistic(widget.expenseToEdit!.id!);
      final success =
          await expenseService.deleteExpense(widget.expenseToEdit!.id!);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
      } else {
        expenseService.addExpenseOptimistic(widget.expenseToEdit!);
        _showErrorSnackbar(
            expenseService.errorMessage ?? 'Failed to delete expense');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Expense' : 'Add Expense'),
        centerTitle: true,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Expense',
              onPressed: _isSubmitting ? null : _confirmDelete,
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Amount Field
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: colorScheme.primary,
                        ),
                        suffixText: 'USD',
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n <= 0) {
                          return 'Enter a valid positive amount';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Category Chips
                Text(
                  'Category',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: kDefaultExpenseCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = kDefaultExpenseCategories[index];
                      return ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = category),
                        selectedColor: colorScheme.primary.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _selectedCategory == category
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                          fontWeight: _selectedCategory == category
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(
                          color: _selectedCategory == category
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Date Picker
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: Icon(
                      Icons.calendar_today_outlined,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      DateFormat(kDisplayDateFormat).format(_selectedDate),
                      style: theme.textTheme.bodyLarge,
                    ),
                    trailing: Icon(
                      Icons.arrow_drop_down,
                      color: colorScheme.secondary,
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(height: 24),

                // Notes
                Text(
                  'Notes (Optional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Add any details about this expense...',
                        border: InputBorder.none,
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isEditMode ? 'Save Changes' : 'Add Expense',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
