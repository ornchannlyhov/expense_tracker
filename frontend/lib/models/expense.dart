import 'package:intl/intl.dart';
import '../utils/constants.dart';

class Expense {
  final int? id;
  final int userId;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;

  Expense(
      {this.id,
      required this.userId,
      required this.amount,
      required this.category,
      required this.date,
      this.notes});

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? json['ID'],
      userId: json['user_id'] ?? json['USER_ID'] ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0.0') ?? 0.0,
      category: json['category'] ?? json['CATEGORY'] ?? 'Other',
      date: DateTime.tryParse(json['date'] ?? json['DATE'] ?? '') ??
          DateTime.now(),
      notes: json['notes'] ?? json['NOTES'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'amount': amount,
      'category': category,
      'date': DateFormat(kApiDateFormat).format(date),
      'notes': notes,
    };
    if (id != null) data['id'] = id;
    return data;
  }

  String get formattedDate => DateFormat(kDisplayDateFormat).format(date);
  String get formattedAmount =>
      NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          amount == other.amount &&
          category == other.category &&
          date == other.date &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      amount.hashCode ^
      category.hashCode ^
      date.hashCode ^
      notes.hashCode;
}
