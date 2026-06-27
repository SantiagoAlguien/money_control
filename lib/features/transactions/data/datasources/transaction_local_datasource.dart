import 'package:money_control/core/constants/app_constants.dart';
import 'package:money_control/features/transactions/data/models/transaction_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Fecha: 2026-06-26
// Contrato de la fuente de datos local para transacciones.
abstract class TransactionLocalDatasource {
  Future<void> init();
  Future<void> insert(TransactionModel transaction);
  Future<List<TransactionModel>> getAll();
  Future<Map<String, double>> getMonthlySummary(DateTime month);
  Future<void> update(TransactionModel transaction);
  Future<void> delete(String id);
}

// Fecha: 2026-06-26
// Implementación de SQLite para almacenar transacciones localmente.
class TransactionLocalDatasourceImpl implements TransactionLocalDatasource {
  Database? _database;

  // Fecha: 2026-06-26
  // Obtiene la base de datos, inicializándola solo si es necesario.
  Future<Database> get _db async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Fecha: 2026-06-26
  // Abre o crea la base de datos. Aplica migraciones entre versiones.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Fecha: 2026-06-26
  // Crea la tabla transactions en la versión inicial de la base de datos.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bank TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        transactionDate TEXT NOT NULL,
        originalText TEXT NOT NULL,
        source TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        description TEXT
      )
    ''');
  }

  // Fecha: 2026-06-26
  // Aplica migraciones cuando cambia la versión de la base de datos.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migración V2: agrega la columna description para motivo/destino.
      await db.execute('ALTER TABLE transactions ADD COLUMN description TEXT');
    }
  }

  @override
  Future<void> init() async {
    await _db;
  }

  // Fecha: 2026-06-26
  // Inserta una nueva transacción. El id es autogenerado, por eso se elimina del mapa.
  @override
  Future<void> insert(TransactionModel transaction) async {
    final db = await _db;
    await db.insert('transactions', transaction.toMap()..remove('id'));
  }

  // Fecha: 2026-06-26
  // Obtiene todas las transacciones ordenadas por fecha descendente.
  @override
  Future<List<TransactionModel>> getAll() async {
    final db = await _db;
    final maps = await db.query(
      'transactions',
      orderBy: 'transactionDate DESC, createdAt DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  // Fecha: 2026-06-26
  // Calcula ingresos, gastos y saldo de un mes específico.
  // Los movimientos neutral no suman ni restan.
  @override
  Future<Map<String, double>> getMonthlySummary(DateTime month) async {
    final db = await _db;
    final start = DateTime(month.year, month.month, 1).toIso8601String();
    final end = DateTime(month.year, month.month + 1, 1).toIso8601String();

    final maps = await db.query(
      'transactions',
      where: 'transactionDate >= ? AND transactionDate < ?',
      whereArgs: [start, end],
    );

    double income = 0;
    double expense = 0;

    for (final map in maps) {
      final type = map['type'] as String;
      final amount = map['amount'] as double;
      if (type == 'income') {
        income += amount;
      } else if (type == 'expense') {
        expense += amount;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  // Fecha: 2026-06-26
  // Actualiza una transacción existente identificada por su id.
  @override
  Future<void> update(TransactionModel transaction) async {
    final db = await _db;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Fecha: 2026-06-26
  // Elimina una transacción por su id.
  @override
  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
