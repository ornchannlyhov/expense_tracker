import 'package:flutter/material.dart';
import 'package:frontend/screens/expense/add_edit_expense.dart';
import 'package:frontend/screens/expense/expense_detail.dart';
import 'package:frontend/screens/expense/expense_list_screen.dart';
import 'package:frontend/screens/expense/monthly_analytics_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';
import '../utils/constants.dart';
import '../widgets/month_picker.dart';
import '../widgets/expense_card.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = homeRoute;
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await Provider.of<ExpenseService>(context, listen: false)
        .fetchExpenses(year: _selectedMonth.year, month: _selectedMonth.month);
  }

  void _onMonthChanged(DateTime newMonth) {
    setState(() => _selectedMonth = newMonth);
    Provider.of<ExpenseService>(context, listen: false)
        .fetchExpenses(year: newMonth.year, month: newMonth.month);
  }

  Future<void> _navigateToAddExpense() async {
    await Navigator.of(context).pushNamed(AddEditExpenseScreen.routeName);
  }

  Future<void> _navigateToExpenseList() async {
    await Navigator.of(context).pushNamed(ExpenseListScreen.routeName);
  }

  Future<void> _navigateToDetailScreen(Expense expense) async {
    await Navigator.of(context).pushNamed(
      ExpenseDetailScreen.routeName,
      arguments: expense,
    );
  }

  void _navigateToAnalytics() {
    Navigator.of(context).pushNamed(MonthlyAnalyticsScreen.routeName);
  }

  void _logout() async {
    await Provider.of<AuthService>(context, listen: false).logout();
    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Welcome, ${authService.user?.username ?? 'User'}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Consumer<ExpenseService>(
        builder: (context, expenseService, child) {
          final expenses = expenseService.getExpensesForMonth(
              _selectedMonth.year, _selectedMonth.month);
          final totalSpending = expenses.fold<double>(
              0.0, (sum, e) => sum + (e.amount > 0 ? e.amount : 0));
          final recentExpenses = expenses.take(5).toList();

          return RefreshIndicator(
            onRefresh: () => expenseService.fetchExpenses(
              year: _selectedMonth.year,
              month: _selectedMonth.month,
              forceRefresh: true,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  MonthPicker(
                    initialDate: _selectedMonth,
                    onMonthSelected: _onMonthChanged,
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _navigateToAnalytics,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: theme.colorScheme.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Monthly Summary',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  Icon(
                                    Icons.insights,
                                    color: theme.colorScheme.onPrimaryContainer
                                        .withOpacity(0.7),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                NumberFormat.currency(
                                        symbol: '\$', decimalDigits: 2)
                                    .format(totalSpending),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to view detailed analytics',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (expenseService.isLoading && expenses.isEmpty)
                    const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()))
                  else if (expenses.isEmpty)
                    const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'No expenses this month',
                            style: TextStyle(fontSize: 16),
                          ),
                        ))
                  else ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Expenses',
                          style: theme.textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: _navigateToExpenseList,
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...recentExpenses.map((exp) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: ExpenseCard(
                            expense: exp,
                            onTap: () => _navigateToDetailScreen(exp),
                          ),
                        )),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        tooltip: 'Add New Expense',
        child: const Icon(Icons.add),
      ),
    );
  }
}
