import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';

class ParseNotification {
  const ParseNotification();

  Transaction? call(
    String text, {
    String source = 'notification',
    DateTime? receivedAt,
  }) {
    final normalized = _normalize(text);
    final category = _detectCategory(normalized);

    if (category == null) return null;

    final amount = _extractAmount(normalized);
    if (amount == null) return null;

    final date = _extractDate(normalized, receivedAt);
    final bank = _extractBank(normalized, source);
    final type = _detectType(category, normalized);

    return Transaction(
      bank: bank,
      amount: amount,
      type: type,
      category: category,
      transactionDate: date,
      originalText: text,
      source: source,
      createdAt: DateTime.now(),
    );
  }

  String _normalize(String text) {
    return text
        .toUpperCase()
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('Ñ', 'N')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll('/', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Category? _detectCategory(String text) {
    if (text.contains('NOMINA')) return Category.payroll;
    if (text.contains('ENVIASTE') ||
        text.contains('ENVIO') ||
        text.contains('TE ENVIARON')) {
      return Category.transfer;
    }
    if (text.contains('TRANSFERENCIA') || text.contains('TRANSFERENCIAS')) {
      return Category.transfer;
    }
    if (text.contains('RENDIMIENTO') || text.contains('RENDIMIENTOS')) {
      return Category.performance;
    }
    if (text.contains('COMPRA')) return Category.purchase;
    if (text.contains('RETIRO')) return Category.withdrawal;
    return null;
  }

  MovementType _detectType(Category category, String text) {
    if (text.contains('TE ENVIARON')) return MovementType.income;
    return _typeForCategory(category);
  }

  MovementType _typeForCategory(Category category) {
    switch (category) {
      case Category.payroll:
      case Category.performance:
        return MovementType.income;
      case Category.transfer:
      case Category.purchase:
      case Category.withdrawal:
      case Category.other:
        return MovementType.expense;
    }
  }

  double? _extractAmount(String text) {
    final pattern = RegExp(r'\$\s?(\d[\d.,]*)');
    final match = pattern.firstMatch(text);
    if (match == null) return null;

    var raw = match.group(1)!;
    raw = raw.replaceAll(RegExp(r'[.,]$'), '');

    final hasThousandSeparatorDots = RegExp(r'\d\.\d{3}').hasMatch(raw);
    final hasThousandSeparatorCommas = RegExp(r'\d,\d{3}').hasMatch(raw);

    String cleaned;
    if (hasThousandSeparatorDots) {
      cleaned = raw.replaceAll('.', '').replaceAll(',', '.');
    } else if (hasThousandSeparatorCommas) {
      cleaned = raw.replaceAll(',', '');
    } else if (raw.contains(',')) {
      cleaned = raw.replaceAll(',', '.');
    } else {
      cleaned = raw;
    }

    return double.tryParse(cleaned);
  }

  DateTime _extractDate(String text, DateTime? receivedAt) {
    final pattern = RegExp(r'(\d{4})\.(\d{2})\.(\d{2})');
    final match = pattern.firstMatch(text);
    if (match != null) {
      final year = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final day = int.parse(match.group(3)!);
      return DateTime(year, month, day);
    }
    return receivedAt ?? DateTime.now();
  }

  String _extractBank(String text, String source) {
    if (text.contains('CAJA SOCIAL')) return 'Caja Social';
    if (source.toLowerCase().contains('caja')) return 'Caja Social';
    return 'Desconocido';
  }
}
