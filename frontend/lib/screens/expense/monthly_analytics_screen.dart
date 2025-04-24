// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend/models/expense.dart';
import 'package:frontend/services/expense_service.dart';
import 'package:frontend/widgets/month_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MonthlyAnalyticsScreen extends StatefulWidget {
  static const routeName = '/monthly-analytics';
  const MonthlyAnalyticsScreen({super.key});

  @override
  State<MonthlyAnalyticsScreen> createState() => _MonthlyAnalyticsScreenState();
}

class _MonthlyAnalyticsScreenState extends State<MonthlyAnalyticsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  late List<ChartData> _chartData = [];
  double _totalSpending = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final expenseService = Provider.of<ExpenseService>(context, listen: false);
    await expenseService.fetchExpenses(
      year: _selectedMonth.year,
      month: _selectedMonth.month,
    );
    
    if (mounted) {
      _updateChartData(expenseService);
    }
  }

  void _updateChartData(ExpenseService expenseService) {
    final expenses = expenseService.getExpensesForMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    
    setState(() {
      _chartData = _prepareChartData(expenses);
      _totalSpending = expenses.fold<double>(
        0.0, (sum, e) => sum + (e.amount > 0 ? e.amount : 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Analytics'),
        centerTitle: true,
      ),
      body: Consumer<ExpenseService>(
        builder: (context, expenseService, child) {
          if (expenseService.isLoading && _chartData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (expenseService.errorMessage != null) {
            return Center(
              child: Text(
                expenseService.errorMessage!,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  MonthPicker(
                    initialDate: _selectedMonth,
                    onMonthSelected: (newMonth) {
                      setState(() => _selectedMonth = newMonth);
                      _fetchData();
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSummaryCard(context),
                  const SizedBox(height: 24),
                  if (_chartData.isNotEmpty)
                    SizedBox(
                      height: 400,
                      child: SfCircularChart(
                        title: ChartTitle(
                          text: 'Spending by Category',
                          textStyle: theme.textTheme.titleLarge,
                        ),
                        legend: Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap,
                          position: LegendPosition.bottom,
                          textStyle: theme.textTheme.bodyMedium,
                        ),
                        series: <CircularSeries>[
                          PieSeries<ChartData, String>(
                            dataSource: _chartData,
                            xValueMapper: (ChartData data, _) => data.category,
                            yValueMapper: (ChartData data, _) => data.amount,
                            dataLabelMapper: (ChartData data, _) =>
                                '${data.category}\n${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(data.amount)}',
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                              textStyle: theme.textTheme.bodySmall,
                            ),
                            pointColorMapper: (ChartData data, _) => data.color,
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(
                      height: 300,
                      child: Center(child: Text('No expenses this month')),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Total Spending for ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                  .format(_totalSpending),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> _prepareChartData(List<Expense> expenses) {
    final categoryTotals = <String, double>{};

    for (final expense in expenses.where((e) => e.amount > 0)) {
      categoryTotals.update(
        expense.category,
        (v) => v + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return categoryTotals.entries
        .map((e) => ChartData(
              e.key,
              e.value,
              _getCategoryColor(e.key),
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];
    return colors[category.hashCode % colors.length];
  }
}

class ChartData {
  ChartData(this.category, this.amount, this.color);
  final String category;
  final double amount;
  final Color color;
}