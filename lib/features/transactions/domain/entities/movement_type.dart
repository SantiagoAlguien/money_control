enum MovementType {
  income('income'),
  expense('expense');

  const MovementType(this.value);
  final String value;

  static MovementType fromValue(String value) {
    return MovementType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MovementType.expense,
    );
  }
}
