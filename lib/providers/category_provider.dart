import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../services/database_helper.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  List<Category> get expenseCategories =>
      _categories.where((c) => c.type == 'expense').toList();

  List<Category> get incomeCategories =>
      _categories.where((c) => c.type == 'income').toList();

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _dbHelper.getAllCategories();
    } catch (e) {
      // Handle error
      print('Error loading categories: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    try {
      await _dbHelper.insertCategory(category);
      await loadCategories(); // Refresh the list
    } catch (e) {
      // Handle error
      print('Error adding category: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _dbHelper.updateCategory(category);
      await loadCategories(); // Refresh the list
    } catch (e) {
      // Handle error
      print('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _dbHelper.deleteCategory(id);
      await loadCategories(); // Refresh the list
    } catch (e) {
      // Handle error
      print('Error deleting category: $e');
    }
  }

  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null; // Not found
    }
  }
}
