import 'package:money_control/core/constants/app_constants.dart';
import 'package:money_control/features/transactions/data/models/transaction_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class TransactionLocalDatasource {
  Future<void> init();
  Future<void> insert(TransactionModel transaction);
  Future<List<TransactionModel>> getAll();
  Future<Map<String, double>> getMonthlySummary(DateTime month);
}

class TransactionLocalDatasourceImpl implements TransactionLocalDatasource {
  Database? _database;

  Future<Database> get _db async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: (db, version) async {
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
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<void> init() async {
    await _db;
  }

  @override
  Future<void> insert(TransactionModel transaction) async {
    final db = await _db;
    await db.insert('transactions', transaction.toMap()
      ..remove('id'));
  }

  @override
  Future<List<TransactionModel>> getAll() async {
    final db = await _db;
    final maps = await db.query(
      'transactions',
      orderBy: 'transactionDate DESC, createdAt DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

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
      } else {
        expense += amount;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }
}
