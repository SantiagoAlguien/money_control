import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart'
    as domain;

// Fecha: 2026-06-26
// Modelo de datos que representa una transacción en la capa de datos.
// Se encarga de convertir entre la entidad de dominio y el mapa de SQLite.
class TransactionModel {
  final String? id;
  final String bank;
  final double amount;
  final String type;
  final String category;
  final String transactionDate;
  final String originalText;
  final String source;
  final String createdAt;
  final String? description;

  const TransactionModel({
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
  // Crea un modelo a partir de una entidad de dominio.
  factory TransactionModel.fromEntity(domain.Transaction entity) {
    return TransactionModel(
      id: entity.id,
      bank: entity.bank,
      amount: entity.amount,
      type: entity.type.value,
      category: entity.category.value,
      transactionDate: entity.transactionDate.toIso8601String(),
      originalText: entity.originalText,
      source: entity.source,
      createdAt: entity.createdAt.toIso8601String(),
      description: entity.description,
    );
  }

  // Fecha: 2026-06-26
  // Convierte el modelo a la entidad de dominio.
  domain.Transaction toEntity() {
    return domain.Transaction(
      id: id,
      bank: bank,
      amount: amount,
      type: MovementType.fromValue(type),
      category: Category.fromValue(category),
      transactionDate: DateTime.parse(transactionDate),
      originalText: originalText,
      source: source,
      createdAt: DateTime.parse(createdAt),
      description: description,
    );
  }

  // Fecha: 2026-06-26
  // Convierte el modelo a un mapa para guardar en SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bank': bank,
      'amount': amount,
      'type': type,
      'category': category,
      'transactionDate': transactionDate,
      'originalText': originalText,
      'source': source,
      'createdAt': createdAt,
      'description': description,
    };
  }

  // Fecha: 2026-06-26
  // Crea un modelo a partir de un mapa de SQLite.
  // El id es INTEGER en la base de datos, por eso se convierte con toString().
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id']?.toString(),
      bank: map['bank'] as String,
      amount: map['amount'] as double,
      type: map['type'] as String,
      category: map['category'] as String,
      transactionDate: map['transactionDate'] as String,
      originalText: map['originalText'] as String,
      source: map['source'] as String,
      createdAt: map['createdAt'] as String,
      description: map['description'] as String?,
    );
  }

  // Fecha: 2026-06-26
  // Crea una copia del modelo con los campos que se deseen actualizar.
  TransactionModel copyWith({
    String? id,
    String? bank,
    double? amount,
    String? type,
    String? category,
    String? transactionDate,
    String? originalText,
    String? source,
    String? createdAt,
    String? description,
  }) {
    return TransactionModel(
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
