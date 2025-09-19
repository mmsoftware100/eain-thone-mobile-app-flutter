import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/database_helper.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  // Initialize and check if user is logged in
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _user = await _databaseHelper.getUser();
      _isAuthenticated = _user != null && _user!.token != null;
      _clearError();
    } catch (e) {
      _setError('Failed to initialize auth: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      // TODO: Replace with actual API call
      // For now, simulate login with dummy data
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate successful login
      final user = User(
        id: 1,
        name: 'Demo User',
        email: email,
        token: 'dummy_token_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user to local database
      await _databaseHelper.deleteUser(); // Clear existing user
      await _databaseHelper.insertUser(user);
      
      _user = user;
      _isAuthenticated = true;
      _clearError();
      return true;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register user
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      // TODO: Replace with actual API call
      // For now, simulate registration with dummy data
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate successful registration
      final user = User(
        id: 1,
        name: name,
        email: email,
        token: 'dummy_token_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user to local database
      await _databaseHelper.deleteUser(); // Clear existing user
      await _databaseHelper.insertUser(user);
      
      _user = user;
      _isAuthenticated = true;
      _clearError();
      return true;
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _databaseHelper.deleteUser();
      _user = null;
      _isAuthenticated = false;
      _clearError();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(String name, String email) async {
    if (_user == null) return false;
    
    _setLoading(true);
    try {
      final updatedUser = _user!.copyWith(
        name: name,
        email: email,
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.updateUser(updatedUser);
      _user = updatedUser;
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user token (for sync purposes)
  Future<void> updateToken(String token) async {
    if (_user == null) return;
    
    try {
      final updatedUser = _user!.copyWith(
        token: token,
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update token: $e');
    }
  }

  // Check if user needs to login
  bool get needsLogin => !_isAuthenticated || _user?.token == null;

  // Get authorization header for API calls
  Map<String, String>? get authHeaders {
    if (_user?.token == null) return null;
    return {
      'Authorization': 'Bearer ${_user!.token}',
      'Content-Type': 'application/json',
    };
  }

  // Clear error
  void clearError() {
    _clearError();
  }

  // Private helper methods
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
}