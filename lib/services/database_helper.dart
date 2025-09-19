import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        serverId TEXT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        date INTEGER NOT NULL,
        userId TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        token TEXT,
        createdAt INTEGER,
        updatedAt INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Check if columns exist before adding them
      var tableInfo = await db.rawQuery("PRAGMA table_info(transactions)");
      var columnNames = tableInfo.map((column) => column['name'] as String).toList();
      
      if (!columnNames.contains('serverId')) {
        await db.execute('ALTER TABLE transactions ADD COLUMN serverId TEXT');
      }
      if (!columnNames.contains('category')) {
        await db.execute('ALTER TABLE transactions ADD COLUMN category TEXT NOT NULL DEFAULT ""');
      }
      if (!columnNames.contains('userId')) {
        await db.execute('ALTER TABLE transactions ADD COLUMN userId TEXT');
      }
    }
  }

  // Transaction CRUD operations
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<Transaction?> getTransaction(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Transaction>> getUnsyncedTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markTransactionAsSynced(int id, String serverId) async {
    final db = await database;
    await db.update(
      'transactions',
      {
        'isSynced': 1,
        'serverId': serverId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      ['income'],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getTotalExpense() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      ['expense'],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getCurrentMonthIncome() async {
    final db = await database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ? AND date >= ? AND date <= ?',
      [
        'income',
        startOfMonth.millisecondsSinceEpoch,
        endOfMonth.millisecondsSinceEpoch,
      ],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getCurrentMonthExpense() async {
    final db = await database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ? AND date >= ? AND date <= ?',
      [
        'expense',
        startOfMonth.millisecondsSinceEpoch,
        endOfMonth.millisecondsSinceEpoch,
      ],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  // User CRUD operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser() async {
    final db = await database;
    return await db.delete('users');
  }

  // Utility methods
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('users');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}