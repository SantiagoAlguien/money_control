// Fecha: 2026-06-28
// Caso de uso que sugiere palabras clave a partir del texto de una notificación.
class SuggestKeywords {
  const SuggestKeywords();

  // Palabras irrelevantes que se ignoran al extraer candidatos.
  static const _stopwords = {
    'EL', 'LA', 'DE', 'EN', 'Y', 'A', 'UN', 'UNA', 'CON', 'POR', 'PARA',
    'SE', 'TE', 'LE', 'LO', 'ME', 'MI', 'TU', 'SU', 'AL', 'DEL', 'QUE', 'ES',
    'SON', 'ESTA', 'ESTE', 'FUE', 'SER', 'SERA', 'HAY', 'MAS', 'MENOS', 'OO',
    'NO', 'SI', 'TUVO', 'HA', 'HAN', 'HE', 'HABER', 'OTRO', 'OTRA', 'ALGUN',
    'ALGUNA', 'CADA', 'TODO', 'TODOS', 'TODAS', 'MUCHO', 'MUCHA', 'MUCHOS',
    'POCO', 'POCA', 'PEQUE', 'BANCO', 'CUENTA', 'APP', 'APLICACION', 'MOVIL',
    'BANCARIO', 'INFORMACION', 'INFO', 'LINEA', 'AMIGA', 'PREFERIDA',
  };

  // Palabras del dominio financiero que tienen mayor prioridad.
  static const _financialKeywords = {
    'TRANSFERENCIA',
    'TRANSFER',
    'ENVIO',
    'ENVIÓ',
    'ENVIASTE',
    'RECIBISTE',
    'RECIBIO',
    'RECIBIÓ',
    'DEPOSITARON',
    'DEPOSITO',
    'DEPÓSITO',
    'RETIRO',
    'RETIRASTE',
    'COMPRA',
    'COMPRASTE',
    'NOMINA',
    'NÓMINA',
    'RENDIMIENTO',
    'RENDIMIENTOS',
    'PAGO',
    'PAGASTE',
    'PAGAR',
    'ABONO',
    'ABONARON',
    'COBRO',
    'COBRASTE',
    'DINERO',
    'PLATA',
    'BRE',
    'NEQUI',
    'CAJA',
    'SOCIAL',
    'DAVIPLATA',
    'DAVIVIENDA',
    'BANCOLOMBIA',
    'LLAVE',
    'CUENTAS',
    'PROPIAS',
    'TERCEROS',
    'INMEDIATOS',
    'PAGOS',
    'AHORRO',
    'CORRIENTE',
    'TARJETA',
    'DEBITO',
    'CRÉDITO',
    'CREDITO',
  };

  // Fecha: 2026-06-28
  // Devuelve una lista de palabras clave candidatas ordenadas por relevancia.
  List<String> call(String text) {
    final normalized = _normalize(text);
    final words = normalized
        .split(' ')
        .where((w) => w.length >= 3)
        .where((w) => !_stopwords.contains(w))
        .where((w) => !_isNumeric(w))
        .toList();

    final candidates = <String>{};
    for (final word in words) {
      candidates.add(word);
    }

    return candidates.toList()
      ..sort((a, b) {
        final aIsFinancial = _financialKeywords.contains(a) ? 1 : 0;
        final bIsFinancial = _financialKeywords.contains(b) ? 1 : 0;
        if (aIsFinancial != bIsFinancial) {
          return bIsFinancial - aIsFinancial;
        }
        return b.length.compareTo(a.length);
      })
      ..take(5).toList();
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
        .replaceAll(RegExp(r'[^A-Z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _isNumeric(String text) {
    return double.tryParse(text.replaceAll('.', '').replaceAll(',', '')) != null;
  }
}
