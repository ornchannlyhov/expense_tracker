// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import '../../utils/constants.dart';
import 'add_edit_expense.dart';

class ExpenseDetailScreen extends StatefulWidget {
  static const routeName = expenseDetailRoute;
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  bool _isDeleting = false;

  void _navigateToEditScreen() => Navigator.of(context).pushReplacementNamed(
        AddEditExpenseScreen.routeName,
        arguments: widget.expense,
      );

  Future<void> _confirmDelete() async {
    final expenseService = context.read<ExpenseService>();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text('This will permanently delete "${widget.expense.category}" expense.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      try {
        final success = await expenseService.deleteExpense(widget.expense.id!);
        if (!mounted) return;
        
        if (success) {
          _showSuccessSnackbar('Expense deleted successfully');
          Navigator.of(context).pop();
        } else {
          _showErrorSnackbar(expenseService.errorMessage ?? 'Failed to delete expense');
        }
      } finally {
        if (mounted) {
          setState(() => _isDeleting = false);
        }
      }
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

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormatted = DateFormat('EEEE, MMMM d, y').format(widget.expense.date);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense.category),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _isDeleting ? null : _navigateToEditScreen,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _isDeleting ? null : _confirmDelete,
            tooltip: 'Delete',
            color: colorScheme.error,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Expense Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Amount
                    _buildDetailItem(
                      context,
                      icon: Icons.attach_money,
                      label: 'Amount',
                      value: widget.expense.formattedAmount,
                      valueStyle: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Divider(height: 24, thickness: 1),
                    
                    // Category
                    _buildDetailItem(
                      context,
                      icon: Icons.category,
                      label: 'Category',
                      value: widget.expense.category,
                      valueStyle: theme.textTheme.titleLarge,
                    ),
                    const Divider(height: 24, thickness: 1),
                    
                    // Date
                    _buildDetailItem(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: dateFormatted,
                      valueStyle: theme.textTheme.titleMedium,
                    ),
                    const Divider(height: 24, thickness: 1),
                    
                    // Notes
                    _buildDetailItem(
                      context,
                      icon: Icons.notes,
                      label: 'Notes',
                      value: widget.expense.notes?.isNotEmpty ?? false
                          ? widget.expense.notes!
                          : 'No notes added',
                      valueStyle: widget.expense.notes?.isNotEmpty ?? false
                          ? theme.textTheme.bodyLarge
                          : theme.textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                      isMultiline: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            if (_isDeleting)
              const CircularProgressIndicator()
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      onPressed: _navigateToEditScreen,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      onPressed: _confirmDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.errorContainer,
                        foregroundColor: colorScheme.onErrorContainer,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
    bool isMultiline = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: valueStyle ??
                      theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}