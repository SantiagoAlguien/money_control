import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';

class Transaction {
  final String? id;
  final String bank;
  final double amount;
  final MovementType type;
  final Category category;
  final DateTime transactionDate;
  final String originalText;
  final String source;
  final DateTime createdAt;

  const Transaction({
    this.id,
    required this.bank,
    required this.amount,
    required this.type,
    required this.category,
    required this.transactionDate,
    required this.originalText,
    required this.source,
    required this.createdAt,
  });

  Transaction copyWith({
    String? id,
    String? bank,
    double? amount,
    MovementType? type,
    Category? category,
    DateTime? transactionDate,
    String? originalText,
    String? source,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      bank: bank ?? this.bank,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      transactionDate: transactionDate ?? this.transactionDate,
      originalText: originalText ?? this.originalText,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
