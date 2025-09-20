import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/category.dart';
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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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

    // Create categories table
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon INTEGER NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        serverId TEXT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        categoryId INTEGER NOT NULL,
        type TEXT NOT NULL,
        date INTEGER NOT NULL,
        userId TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Logic for upgrading from version 1 to 2
      var tableInfo = await db.rawQuery("PRAGMA table_info(transactions)");
      var columnNames =
          tableInfo.map((column) => column['name'] as String).toList();

      if (!columnNames.contains('serverId')) {
        await db.execute('ALTER TABLE transactions ADD COLUMN serverId TEXT');
      }
      if (!columnNames.contains('category')) {
        await db.execute(
            'ALTER TABLE transactions ADD COLUMN category TEXT NOT NULL DEFAULT ""');
      }
      if (!columnNames.contains('userId')) {
        await db.execute('ALTER TABLE transactions ADD COLUMN userId TEXT');
      }
    }
    if (oldVersion < 3) {
      // Logic for upgrading from version 2 to 3
      await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon INTEGER NOT NULL,
          type TEXT NOT NULL
        )
      ''');

      // Insert default categories
      await _insertDefaultCategories(db);

      // Create a new transactions table with the updated schema
      await db.execute('''
        CREATE TABLE transactions_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          serverId TEXT,
          description TEXT NOT NULL,
          amount REAL NOT NULL,
          categoryId INTEGER,
          type TEXT NOT NULL,
          date INTEGER NOT NULL,
          userId TEXT,
          isSynced INTEGER NOT NULL DEFAULT 0,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL,
          FOREIGN KEY (categoryId) REFERENCES categories(id)
        )
      ''');

      // Migrate data from the old transactions table to the new one
      var oldTransactions = await db.query('transactions');
      var categories = await db.query('categories');

      for (var transaction in oldTransactions) {
        var categoryName = transaction['category'] as String;
        var transactionType = transaction['type'] as String;
        var category = categories.firstWhere(
          (cat) =>
              cat['name'] == categoryName && cat['type'] == transactionType,
          orElse: () => categories.firstWhere(
            (cat) => cat['name'] == 'Other' && cat['type'] == transactionType,
          ),
        );

        var newTransaction = Map<String, dynamic>.from(transaction);
        newTransaction['categoryId'] = category['id'];
        newTransaction.remove('category');
        await db.insert('transactions_new', newTransaction);
      }

      // Drop the old transactions table and rename the new one
      await db.execute('DROP TABLE transactions');
      await db.execute('ALTER TABLE transactions_new RENAME TO transactions');
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      // Expenses
      {'name': 'Food', 'icon': Icons.restaurant.codePoint, 'type': 'expense'},
      {'name': 'Transport', 'icon': Icons.directions_car.codePoint, 'type': 'expense'},
      {'name': 'Shopping', 'icon': Icons.shopping_bag.codePoint, 'type': 'expense'},
      {'name': 'Entertainment', 'icon': Icons.movie.codePoint, 'type': 'expense'},
      {'name': 'Health', 'icon': Icons.local_hospital.codePoint, 'type': 'expense'},
      {'name': 'Education', 'icon': Icons.school.codePoint, 'type': 'expense'},
      {'name': 'Utilities', 'icon': Icons.electrical_services.codePoint, 'type': 'expense'},
      {'name': 'Other', 'icon': Icons.category.codePoint, 'type': 'expense'},
      // Incomes
      {'name': 'Salary', 'icon': Icons.work.codePoint, 'type': 'income'},
      {'name': 'Business', 'icon': Icons.business.codePoint, 'type': 'income'},
      {'name': 'Investment', 'icon': Icons.trending_up.codePoint, 'type': 'income'},
      {'name': 'Gift', 'icon': Icons.card_giftcard.codePoint, 'type': 'income'},
      {'name': 'Other', 'icon': Icons.category.codePoint, 'type': 'income'},
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // Transaction CRUD operations
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  // Category CRUD Operations
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    // Before deleting a category, you might want to handle transactions that use it.
    // For example, re-assign them to a default 'Uncategorized' category.
    // For simplicity, we'll just delete it here.
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
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