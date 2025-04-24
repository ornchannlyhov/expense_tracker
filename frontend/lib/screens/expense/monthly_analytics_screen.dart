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
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  late List<ChartData> _chartData = [];
  double _totalSpending = 0.0;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final expenseService =
          Provider.of<ExpenseService>(context, listen: false);
      await expenseService.fetchExpenses(
        year: _selectedMonth.year,
        month: _selectedMonth.month,
        forceRefresh: true,
      );

      if (!mounted) return;
      _updateChartData(expenseService);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load analytics data';
        _chartData = [];
        _totalSpending = 0.0;
        _isLoading = false;
      });
    }
  }

  void _updateChartData(ExpenseService expenseService) {
    try {
      final expenses = expenseService.getExpensesForMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );

      setState(() {
        _chartData = _prepareChartData(expenses);
        _totalSpending = expenses.fold<double>(
            0.0, (sum, e) => sum + (e.amount > 0 ? e.amount : 0));
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to process chart data';
        _chartData = [];
        _totalSpending = 0.0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Analytics'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Try Again'),
            ),
          ],
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
            if (_chartData.isEmpty)
              const SizedBox(
                height: 300,
                child: Center(child: Text('No expenses this month')),
              )
            else
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
          ],
        ),
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
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Icon(
                  Icons.insights,
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                  .format(_totalSpending),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
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
