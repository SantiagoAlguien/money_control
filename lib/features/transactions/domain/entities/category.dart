enum Category {
  payroll('payroll'),
  transfer('transfer'),
  purchase('purchase'),
  withdrawal('withdrawal'),
  performance('performance'),
  other('other');

  const Category(this.value);
  final String value;

  static Category fromValue(String value) {
    return Category.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Category.other,
    );
  }
}
