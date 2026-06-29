import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';

// Fecha: 2026-06-26
// Entidad que representa una regla de parseo para clasificar notificaciones.
class ParserRule {
  final String? id;
  final String appPackageName;
  final String keyword;
  final Category category;
  final MovementType type;

  const ParserRule({
    this.id,
    required this.appPackageName,
    required this.keyword,
    required this.category,
    required this.type,
  });

  ParserRule copyWith({
    String? id,
    String? appPackageName,
    String? keyword,
    Category? category,
    MovementType? type,
  }) {
    return ParserRule(
      id: id ?? this.id,
      appPackageName: appPackageName ?? this.appPackageName,
      keyword: keyword ?? this.keyword,
      category: category ?? this.category,
      type: type ?? this.type,
    );
  }
}
