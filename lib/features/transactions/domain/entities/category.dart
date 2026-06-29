enum Category {
  nomina('nomina', 'Nómina'),
  transferencia('transferencia', 'Transferencia'),
  compra('compra', 'Compra'),
  retiro('retiro', 'Retiro'),
  rendimiento('rendimiento', 'Rendimiento'),
  otro('otro', 'Otro');

  const Category(this.value, this.displayName);

  // Clave técnica usada en SQLite y reglas de parser.
  final String value;

  // Etiqueta legible en español para la UI.
  final String displayName;

  static Category fromValue(String value) {
    return Category.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Category.otro,
    );
  }
}
