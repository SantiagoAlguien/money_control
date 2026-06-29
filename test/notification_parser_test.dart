import 'package:flutter_test/flutter_test.dart';
import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';
import 'package:money_control/features/transactions/domain/usecases/parse_notification.dart';

void main() {
  late ParseNotification parser;

  setUp(() {
    parser = const ParseNotification();
  });

  group('ParseNotification - mensajes reales de Caja Social', () {
    test('caso 1: envio de 10 pesos a una llave (egreso)', () {
      const text =
          '¡Hola! Enviaste \$10,00 a una llave. Consulta el movimiento en tu cuenta del Banco Caja Social. Mas info en la Linea Amiga #233.';

      final transaction = parser(text, source: 'sms');

      expect(transaction, isNotNull);
      expect(transaction!.bank, 'Caja Social');
      expect(transaction.amount, 10.0);
      expect(transaction.type, MovementType.expense);
      expect(transaction.category, Category.transfer);
    });

    test('caso 6: recibiste 10 pesos por una llave (ingreso)', () {
      const text =
          '¡Hola! Te enviaron \$10,00 con una de tus llaves. Revisa el saldo en tu cuenta de Banco Caja Social. Mas info en la Linea Amiga #233';

      final transaction = parser(text, source: 'sms');

      expect(transaction, isNotNull);
      expect(transaction!.bank, 'Caja Social');
      expect(transaction.amount, 10.0);
      expect(transaction.type, MovementType.income);
      expect(transaction.category, Category.transfer);
    });

    test('caso 2: abono de nomina', () {
      const text =
          'TX EXITOSA en *8128.El 2026.05.30 a las 08:00 un(a) ABONO NOMINA por \$1,000,000.00.Banco Caja Social.';

      final transaction = parser(text, source: 'sms');

      expect(transaction, isNotNull);
      expect(transaction!.bank, 'Caja Social');
      expect(transaction.amount, 1000000.0);
      expect(transaction.type, MovementType.income);
      expect(transaction.category, Category.payroll);
      expect(transaction.transactionDate, DateTime(2026, 5, 30));
    });

    test('caso 3: transferencias cuentas propias', () {
      const text =
          'TX EXITOSA en *8128.El 2026.05.30 a las 12:02 un(a) TRANSFERENCIAS CUENTAS PROPIAS por \$100,000.00.Banco Caja Social.';

      final transaction = parser(text, source: 'sms');

      expect(transaction, isNotNull);
      expect(transaction!.bank, 'Caja Social');
      expect(transaction.amount, 100000.0);
      expect(transaction.type, MovementType.expense);
      expect(transaction.category, Category.transfer);
      expect(transaction.transactionDate, DateTime(2026, 5, 30));
    });

    test('caso 4: compra cuenta de ahorro/corriente', () {
      const text =
          'TX EXITOSA en *8128.El 2026.05.31 a las 14:01 un(a) COMPRA CUENTA DE AHORRO/CORRIENTE por \$80,000.00.Banco Caja Social';

      final transaction = parser(text, source: 'sms');

      expect(transaction, isNotNull);
      expect(transaction!.bank, 'Caja Social');
      expect(transaction.amount, 80000.0);
      expect(transaction.type, MovementType.expense);
      expect(transaction.category, Category.purchase);
      expect(transaction.transactionDate, DateTime(2026, 5, 31));
    });

    test('caso 5: retiro pagos inmediatos', () {
      const text =
          'TX EXITOSA en *8128.El 2026.06.01 a las 19:20 un(a) RETIRO PAGOS INMEDIATOS por \$200,000.00.Banco Caja Social.';

      final transaction = parser(text, source: 'sms');

      expect(transaction, isNotNull);
      expect(transaction!.bank, 'Caja Social');
      expect(transaction.amount, 200000.0);
      expect(transaction.type, MovementType.expense);
      expect(transaction.category, Category.withdrawal);
      expect(transaction.transactionDate, DateTime(2026, 6, 1));
    });

    test('caso 7: nequi recibiste plata por Bre-B', () {
      const text =
          'Te enviaron plata por Bre-B. Te enviaron \$11. Entra a tu app y revisa tu saldo.';

      final transaction = parser(text, source: 'com.nequi.MobileApp');

      expect(transaction, isNotNull);
      expect(transaction!.bank, 'Desconocido');
      expect(transaction.amount, 11.0);
      expect(transaction.type, MovementType.income);
      expect(transaction.category, Category.transfer);
    });
  });
}
