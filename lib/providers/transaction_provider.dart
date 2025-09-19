import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and load transactions
  Future<void> initialize() async {
    await loadTransactions();
  }

  // Load transactions from database
  Future<void> loadTransactions() async {
    _setLoading(true);
    try {
      _transactions = await _databaseHelper.getAllTransactions();
      _clearError();
    } catch (e) {
      _setError('Failed to load transactions: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add new transaction
  Future<void> addTransaction(Transaction transaction) async {
    try {
      final id = await _databaseHelper.insertTransaction(transaction);
      final newTransaction = transaction.copyWith(
        id: id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );
      _transactions.insert(0, newTransaction);
      await _saveTransactions();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add transaction: $e');
      rethrow;
    }
  }

  // Update transaction
  Future<void> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      final updatedTransaction = transaction.copyWith(
        updatedAt: DateTime.now(),
        isSynced: false,
      );
      _transactions[index] = updatedTransaction;
      await _saveTransactions();
      notifyListeners();
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(int id) async {
    try {
      await _databaseHelper.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      await _saveTransactions();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete transaction: $e');
      rethrow;
    }
  }

  // Get monthly summary
  Map<String, double> getMonthlySummary() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    
    final monthlyTransactions = _transactions.where((t) =>
      t.date.isAfter(currentMonth.subtract(const Duration(days: 1))) &&
      t.date.isBefore(nextMonth)
    ).toList();
    
    double totalIncome = 0;
    double totalExpense = 0;
    
    for (final transaction in monthlyTransactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }
    
    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }

  // Refresh transactions
  Future<void> refreshTransactions() async {
    await loadTransactions();
  }

  // Get transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  // Get transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) =>
      t.date.isAfter(start.subtract(const Duration(days: 1))) &&
      t.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  // Get transaction by id
  Transaction? getTransactionById(int id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Save transactions to local storage
  Future<void> _saveTransactions() async {
    try {
      // This would typically save to local storage
      // For now, we'll just update the database through individual operations
      // The actual saving is handled by the database helper in add/update/delete methods
    } catch (e) {
      _setError('Failed to save transactions: $e');
    }
  }

  // Mark transaction as synced
  Future<void> markTransactionAsSynced(int localId) async {
    try {
      final index = _transactions.indexWhere((t) => t.id == localId);
      if (index != -1) {
        _transactions[index] = _transactions[index].copyWith(
          isSynced: true,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to mark transaction as synced: $e');
    }
  }

  // Add synced transactions from server
  Future<void> addSyncedTransactions(List<Transaction> syncedTransactions) async {
    try {
      for (final transaction in syncedTransactions) {
        // Check if transaction already exists by id
        final existingIndex = _transactions.indexWhere(
          (t) => t.id == transaction.id,
        );
        
        if (existingIndex == -1) {
          // New transaction from server
          final id = await _databaseHelper.insertTransaction(transaction);
          _transactions.insert(0, transaction.copyWith(id: id));
        } else {
          // Update existing transaction if server version is newer
          final existing = _transactions[existingIndex];
          if (transaction.updatedAt.isAfter(existing.updatedAt)) {
            await _databaseHelper.updateTransaction(transaction.copyWith(id: existing.id));
            _transactions[existingIndex] = transaction.copyWith(id: existing.id);
          }
        }
      }
      
      // Sort transactions by date
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      _setError('Failed to add synced transactions: $e');
    }
  }

  // Get unsynced transactions
  List<Transaction> getUnsyncedTransactions() {
    return _transactions.where((t) => !t.isSynced).toList();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}