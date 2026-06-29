import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';

// Fecha: 2026-06-26
// Entidad de dominio que representa una transacción financiera.
// Guarda toda la información relevante de un movimiento bancario o manual.
class Transaction {
  final int? id;
  final String bank;
  final double amount;
  final MovementType type;
  final Category category;
  final DateTime transactionDate;
  final String originalText;
  final String source;
  final DateTime createdAt;
  final String? description; // Motivo o destino del movimiento (manual o editado).

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
    this.description,
  });

  // Fecha: 2026-06-26
  // Crea una copia de la transacción con los campos que se deseen actualizar.
  Transaction copyWith({
    int? id,
    String? bank,
    double? amount,
    MovementType? type,
    Category? category,
    DateTime? transactionDate,
    String? originalText,
    String? source,
    DateTime? createdAt,
    String? description,
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
      description: description ?? this.description,
    );
  }
}
