// Fecha: 2026-06-26
// Define los tipos de movimiento financiero que puede tener una transacción.
// - income: ingreso de dinero.
// - expense: egreso de dinero.
// - neutral: movimiento que no afecta el saldo (ej. transferencia entre cuentas propias).
enum MovementType {
  income('income'),
  expense('expense'),
  neutral('neutral');

  const MovementType(this.value);
  final String value;

  // Fecha: 2026-06-26
  // Convierte un valor de texto al enum correspondiente.
  static MovementType fromValue(String value) {
    return MovementType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MovementType.expense,
    );
  }
}
