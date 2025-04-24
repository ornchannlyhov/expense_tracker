import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/expense.dart';
import 'api_service.dart';

class ExpenseService with ChangeNotifier {
  final Dio _dio = getDioInstance();
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;

  List<Expense> getExpensesForMonth(int year, int month) => _expenses
      .where((e) => e.date.year == year && e.date.month == month)
      .toList();

  void _setState({
    bool loading = false,
    String? error,
    List<Expense>? newExpenses,
    bool notify = true,
  }) {
    _isLoading = loading;
    _errorMessage = error;
    if (newExpenses != null) {
      _expenses = newExpenses..sort((a, b) => b.date.compareTo(a.date));
      _lastUpdated = DateTime.now();
    }
    if (notify) notifyListeners();
  }

  Future<void> fetchExpenses(
      {int? year, int? month, bool forceRefresh = false}) async {
    if (!forceRefresh && _expenses.isNotEmpty && !_isLoading) {
      return;
    }

    _setState(loading: true, error: null, notify: false);
    try {
      Map<String, dynamic> queryParams = {};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final response = await _dio.get(
        '/expenses',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          extra: {'refresh': forceRefresh},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] as List;
        _setState(
          loading: false,
          newExpenses: data.map((json) => Expense.fromJson(json)).toList(),
        );
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      _handleExpenseError(e, "Failed to fetch expenses");
    }
  }

  Future<bool> addExpense(Expense expense) async {
    _setState(loading: true, error: null, notify: false);
    try {
      final response = await _dio.post(
        '/expenses',
        data: expense.toJson(),
      );

      if (response.statusCode == 201) {
        final newExpense = Expense.fromJson(response.data['data']);
        _setState(
          loading: false,
          newExpenses: List<Expense>.from(_expenses)..insert(0, newExpense),
        );
        return true;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      _handleExpenseError(e, "Failed to add expense");
      return false;
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    if (expense.id == null) {
      _setState(error: "Update failed: Expense ID missing.");
      return false;
    }

    _setState(loading: true, error: null, notify: false);
    try {
      final response = await _dio.put(
        '/expenses/${expense.id}',
        data: expense.toJson(),
      );

      if (response.statusCode == 200) {
        final updatedExpense = Expense.fromJson(response.data['data']);
        final index = _expenses.indexWhere((e) => e.id == expense.id);

        if (index != -1) {
          final updatedList = List<Expense>.from(_expenses);
          updatedList[index] = updatedExpense;
          _setState(loading: false, newExpenses: updatedList);
        } else {
          await fetchExpenses(forceRefresh: true);
        }
        return true;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      _handleExpenseError(e, "Failed to update expense");
      return false;
    }
  }

  Future<bool> deleteExpense(int expenseId) async {
    _setState(loading: true, error: null, notify: false);
    try {
      final response = await _dio.delete('/expenses/$expenseId');

      if (response.statusCode == 200) {
        _setState(
          loading: false,
          newExpenses: List<Expense>.from(_expenses)
            ..removeWhere((e) => e.id == expenseId),
        );
        return true;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      _handleExpenseError(e, "Failed to delete expense");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getMonthlySummary(int year, int month) async {
    _setState(loading: true, error: null, notify: false);
    try {
      final response = await _dio.get(
        '/expenses/summary',
        queryParameters: {'year': year, 'month': month},
      );

      if (response.statusCode == 200 && response.data != null) {
        _setState(loading: false);
        return response.data['data'];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      _handleExpenseError(e, "Failed to fetch monthly summary");
      return null;
    }
  }

  void _handleExpenseError(Object e, String defaultMessage) {
    _setState(loading: false, error: _parseDioError(e, defaultMessage));
  }

  String _parseDioError(Object e, String defaultMessage) {
    if (e is DioException) {
      if (e.response?.data != null) {
        var data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
        if (data is Map && data.containsKey('error')) {
          return data['error'].toString();
        }
        return data.toString();
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return 'Network error.';
      }
      return e.message ?? defaultMessage;
    }
    return 'An unexpected error occurred: ${e.toString()}';
  }

  // Optimistic update methods for better UX
  void addExpenseOptimistic(Expense expense) {
    _setState(
      newExpenses: List<Expense>.from(_expenses)..insert(0, expense),
      notify: true,
    );
  }

  void updateExpenseOptimistic(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      final updatedList = List<Expense>.from(_expenses);
      updatedList[index] = expense;
      _setState(newExpenses: updatedList, notify: true);
    }
  }

  void removeExpenseOptimistic(int expenseId) {
    _setState(
      newExpenses: List<Expense>.from(_expenses)
        ..removeWhere((e) => e.id == expenseId),
      notify: true,
    );
  }
}
