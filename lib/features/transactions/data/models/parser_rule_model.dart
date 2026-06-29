import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';
import 'package:money_control/features/transactions/domain/entities/parser_rule.dart';

// Fecha: 2026-06-26
// Modelo de datos para las reglas de clasificación de notificaciones.
class ParserRuleModel {
  final String? id;
  final String appPackageName;
  final String keyword;
  final String category;
  final String type;

  const ParserRuleModel({
    this.id,
    required this.appPackageName,
    required this.keyword,
    required this.category,
    required this.type,
  });

  factory ParserRuleModel.fromEntity(ParserRule entity) {
    return ParserRuleModel(
      id: entity.id,
      appPackageName: entity.appPackageName,
      keyword: entity.keyword,
      category: entity.category.value,
      type: entity.type.value,
    );
  }

  ParserRule toEntity() {
    return ParserRule(
      id: id,
      appPackageName: appPackageName,
      keyword: keyword,
      category: Category.fromValue(category),
      type: MovementType.fromValue(type),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appPackageName': appPackageName,
      'keyword': keyword,
      'category': category,
      'type': type,
    };
  }

  factory ParserRuleModel.fromMap(Map<String, dynamic> map) {
    return ParserRuleModel(
      id: map['id']?.toString(),
      appPackageName: map['appPackageName'] as String,
      keyword: map['keyword'] as String,
      category: map['category'] as String,
      type: map['type'] as String,
    );
  }
}
