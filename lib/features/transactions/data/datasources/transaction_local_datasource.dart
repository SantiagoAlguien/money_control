import 'package:money_control/core/constants/app_constants.dart';
import 'package:money_control/features/transactions/data/models/app_config_model.dart';
import 'package:money_control/features/transactions/data/models/parser_rule_model.dart';
import 'package:money_control/features/transactions/data/models/pending_notification_model.dart';
import 'package:money_control/features/transactions/data/models/transaction_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Fecha: 2026-06-26
// Contrato de la fuente de datos local para transacciones y configuración.
abstract class TransactionLocalDatasource {
  Future<void> init();

  // Transacciones
  Future<int> insert(TransactionModel transaction);
  Future<List<TransactionModel>> getAll();
  Future<Map<String, double>> getMonthlySummary(DateTime month);
  Future<void> update(TransactionModel transaction);
  Future<void> delete(int id);

  // Apps de notificaciones
  Future<List<AppConfigModel>> getAppConfigs();
  Future<void> saveAppConfig(AppConfigModel config);
  Future<AppConfigModel?> getAppConfigByPackage(String packageName);

  // Reglas de parser
  Future<List<ParserRuleModel>> getParserRules(String packageName);
  Future<void> saveParserRule(ParserRuleModel rule);

  // Notificaciones pendientes
  Future<void> savePendingNotification(PendingNotificationModel notification);
  Future<List<PendingNotificationModel>> getPendingNotifications();
  Future<void> updatePendingNotificationStatus(String id, String status);
  Future<void> deletePendingNotification(String id);
  Future<void> cleanExpiredPendingNotifications();
}

// Fecha: 2026-06-26
// Implementación de SQLite para almacenar todo localmente.
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
  // Crea todas las tablas en la versión inicial más reciente.
  Future<void> _onCreate(Database db, int version) async {
    await _createV1Tables(db);
    await _createV3Tables(db);
    await _seedDefaultData(db);
  }

  // Fecha: 2026-06-26
  // Aplica migraciones cuando cambia la versión de la base de datos.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN description TEXT');
    }
    if (oldVersion < 3) {
      await _createV3Tables(db);
      await _seedDefaultData(db);
    }
  }

  // Fecha: 2026-06-26
  // Crea la tabla transactions (V1) y su migración V2.
  Future<void> _createV1Tables(Database db) async {
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
  // Crea las tablas de configuración de apps, reglas y notificaciones pendientes.
  Future<void> _createV3Tables(Database db) async {
    await db.execute('''
      CREATE TABLE notification_apps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        packageName TEXT UNIQUE NOT NULL,
        appName TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        autoProcess INTEGER NOT NULL DEFAULT 1,
        bankName TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE parser_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appPackageName TEXT NOT NULL,
        keyword TEXT NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        packageName TEXT NOT NULL,
        title TEXT NOT NULL,
        text TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL,
        expiresAt TEXT NOT NULL
      )
    ''');
  }

  // Fecha: 2026-06-26
  // Inserta las apps y reglas por defecto (Caja Social y Nequi).
  Future<void> _seedDefaultData(Database db) async {
    // Apps por defecto
    await db.insert('notification_apps', {
      'packageName': 'com.samsung.android.messaging',
      'appName': 'Caja Social SMS',
      'enabled': 1,
      'autoProcess': 1,
      'bankName': 'Caja Social',
    });

    await db.insert('notification_apps', {
      'packageName': 'com.nequi.MobileApp',
      'appName': 'Nequi',
      'enabled': 1,
      'autoProcess': 1,
      'bankName': 'Nequi',
    });

    // Reglas por defecto para Caja Social
    final cajaSocialRules = [
      {'keyword': 'NOMINA', 'category': 'payroll', 'type': 'income'},
      {'keyword': 'ENVIASTE', 'category': 'transfer', 'type': 'expense'},
      {'keyword': 'TE ENVIARON', 'category': 'transfer', 'type': 'income'},
      {'keyword': 'TRANSFERENCIA', 'category': 'transfer', 'type': 'expense'},
      {'keyword': 'COMPRA', 'category': 'purchase', 'type': 'expense'},
      {'keyword': 'RETIRO', 'category': 'withdrawal', 'type': 'expense'},
    ];

    for (final rule in cajaSocialRules) {
      await db.insert('parser_rules', {
        'appPackageName': 'com.samsung.android.messaging',
        ...rule,
      });
    }

    // Reglas por defecto para Nequi
    final nequiRules = [
      {
        'keyword': 'TE ENVIARON PLATA',
        'category': 'transfer',
        'type': 'income'
      },
      {
        'keyword': 'ENVIO DE PLATA',
        'category': 'transfer',
        'type': 'expense'
      },
      {
        'keyword': 'ENVÍO DE PLATA',
        'category': 'transfer',
        'type': 'expense'
      },
    ];

    for (final rule in nequiRules) {
      await db.insert('parser_rules', {
        'appPackageName': 'com.nequi.MobileApp',
        ...rule,
      });
    }
  }

  @override
  Future<void> init() async {
    await _db;
  }

  // Fecha: 2026-06-26
  // Inserta una nueva transacción y devuelve el id autogenerado.
  @override
  Future<int> insert(TransactionModel transaction) async {
    final db = await _db;
    return await db.insert('transactions', transaction.toMap()..remove('id'));
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
  // Actualiza una transacción existente.
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
  // Elimina una transacción por id.
  @override
  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fecha: 2026-06-26
  // Obtiene todas las apps configuradas.
  @override
  Future<List<AppConfigModel>> getAppConfigs() async {
    final db = await _db;
    final maps = await db.query('notification_apps');
    return maps.map((map) => AppConfigModel.fromMap(map)).toList();
  }

  // Fecha: 2026-06-26
  // Guarda o actualiza la configuración de una app.
  @override
  Future<void> saveAppConfig(AppConfigModel config) async {
    final db = await _db;
    await db.insert(
      'notification_apps',
      config.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fecha: 2026-06-26
  // Obtiene la configuración de una app por su packageName.
  @override
  Future<AppConfigModel?> getAppConfigByPackage(String packageName) async {
    final db = await _db;
    final maps = await db.query(
      'notification_apps',
      where: 'packageName = ?',
      whereArgs: [packageName],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return AppConfigModel.fromMap(maps.first);
  }

  // Fecha: 2026-06-26
  // Obtiene las reglas de parser de una app.
  @override
  Future<List<ParserRuleModel>> getParserRules(String packageName) async {
    final db = await _db;
    final maps = await db.query(
      'parser_rules',
      where: 'appPackageName = ?',
      whereArgs: [packageName],
    );
    return maps.map((map) => ParserRuleModel.fromMap(map)).toList();
  }

  // Fecha: 2026-06-26
  // Guarda una nueva regla de parser.
  @override
  Future<void> saveParserRule(ParserRuleModel rule) async {
    final db = await _db;
    await db.insert('parser_rules', rule.toMap()..remove('id'));
  }

  // Fecha: 2026-06-26
  // Guarda una notificación pendiente.
  @override
  Future<void> savePendingNotification(
    PendingNotificationModel notification,
  ) async {
    final db = await _db;
    await db.insert(
      'pending_notifications',
      notification.toMap()..remove('id'),
    );
  }

  // Fecha: 2026-06-26
  // Obtiene las notificaciones pendientes ordenadas por fecha descendente.
  @override
  Future<List<PendingNotificationModel>> getPendingNotifications() async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'pending_notifications',
      where: 'status = ? AND expiresAt > ?',
      whereArgs: ['pending', now],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => PendingNotificationModel.fromMap(map)).toList();
  }

  // Fecha: 2026-06-26
  // Actualiza el estado de una notificación pendiente.
  @override
  Future<void> updatePendingNotificationStatus(
    String id,
    String status,
  ) async {
    final db = await _db;
    await db.update(
      'pending_notifications',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fecha: 2026-06-26
  // Elimina una notificación pendiente por id.
  @override
  Future<void> deletePendingNotification(String id) async {
    final db = await _db;
    await db.delete(
      'pending_notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fecha: 2026-06-26
  // Elimina las notificaciones pendientes que ya vencieron.
  @override
  Future<void> cleanExpiredPendingNotifications() async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    await db.delete(
      'pending_notifications',
      where: 'expiresAt <= ?',
      whereArgs: [now],
    );
  }
}
