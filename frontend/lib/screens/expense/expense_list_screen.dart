import 'package:flutter/material.dart';
import 'package:frontend/screens/expense/expense_detail.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import '../../widgets/expense_card.dart';
import '../../utils/constants.dart';
import 'add_edit_expense.dart';

class ExpenseListScreen extends StatefulWidget {
  static const routeName = expenseListRoute;
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final service = Provider.of<ExpenseService>(context, listen: false);
      if (service.expenses.isEmpty && !service.isLoading) {
        service.fetchExpenses();
      }
    });
  }

  void _navigateToAddEditScreen({Expense? expense}) => Navigator.of(context)
      .pushNamed(AddEditExpenseScreen.routeName, arguments: expense);
  void _navigateToDetailScreen(Expense expense) => Navigator.of(context)
      .pushNamed(ExpenseDetailScreen.routeName, arguments: expense);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Expenses'), actions: [
        IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Expense',
            onPressed: () => _navigateToAddEditScreen())
      ]),
      body: Consumer<ExpenseService>(
        builder: (context, expenseService, child) {
          if (expenseService.isLoading && expenseService.expenses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (expenseService.errorMessage != null &&
              expenseService.expenses.isEmpty) {
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Text(
                        'Error: ${expenseService.errorMessage}\nPull down to retry.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent))));
          }
          if (expenseService.expenses.isEmpty) {
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 60, color: Colors.grey),
                  const SizedBox(height: kDefaultPadding),
                  const Text('No expenses recorded yet.',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: kDefaultPadding),
                  ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Expense'),
                      onPressed: () => _navigateToAddEditScreen())
                ]));
          }

          return RefreshIndicator(
            onRefresh: () => expenseService.fetchExpenses(),
            child: ListView.builder(
                padding: const EdgeInsets.only(
                    top: kDefaultPadding * 0.2, bottom: kDefaultPadding * 0.2),
                itemCount: expenseService.expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenseService.expenses[index];
                  return ExpenseCard(
                      expense: expense,
                      onTap: () => _navigateToDetailScreen(expense));
                }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToAddEditScreen(),
          tooltip: 'Add Expense',
          child: const Icon(Icons.add)),
    );
  }
}
