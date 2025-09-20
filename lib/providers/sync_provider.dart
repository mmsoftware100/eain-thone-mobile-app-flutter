import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/api_service.dart';
import 'dart:async';

class SyncProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isOnline = false;
  bool _isSyncing = false;
  bool _autoSyncEnabled = true;
  String? _syncError;
  DateTime? _lastSyncTime;
  Timer? _syncTimer;
  Timer? _connectivityTimer;

  // Getters
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  bool get autoSyncEnabled => _autoSyncEnabled;
  String? get syncError => _syncError;
  DateTime? get lastSyncTime => _lastSyncTime;
  
  String get syncStatus {
    if (_isSyncing) return 'Syncing...';
    if (!_isOnline) return 'Offline';
    if (_syncError != null) return 'Sync Error';
    if (_lastSyncTime != null) {
      final diff = DateTime.now().difference(_lastSyncTime!);
      if (diff.inMinutes < 1) return 'Just synced';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    }
    return 'Never synced';
  }

  SyncProvider() {
    _initConnectivity();
    _startPeriodicSync();
    _startConnectivityCheck();
  }

  // Initialize connectivity monitoring
  Future<void> _initConnectivity() async {
    final connectivity = Connectivity();
    
    // Check initial connectivity
    final results = await connectivity.checkConnectivity();
    await _updateConnectivity(results);
    
    // Listen for connectivity changes
    connectivity.onConnectivityChanged.listen(_updateConnectivity);
  }

  // Update connectivity status with real network test
  Future<void> _updateConnectivity(List<ConnectivityResult> results) async {
    final hasNetworkInterface = results.any((result) => 
      result == ConnectivityResult.mobile || 
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet
    );
    
    if (hasNetworkInterface) {
      // Test real connectivity by pinging the server
      await _testRealConnectivity();
    } else {
      final wasOnline = _isOnline;
      _isOnline = false;
      if (wasOnline) {
        notifyListeners();
      }
    }
  }

  // Test real connectivity by attempting to reach the server
  Future<void> _testRealConnectivity() async {
    try {
      // Try to get sync status from server with a short timeout
      await _apiService.getSyncStatus().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );
      
      final wasOnline = _isOnline;
      _isOnline = true;
      
      if (!wasOnline) {
        // Just came online, trigger sync
        _triggerSync();
        notifyListeners();
      }
    } catch (e) {
      final wasOnline = _isOnline;
      _isOnline = false;
      
      if (wasOnline) {
        notifyListeners();
      }
    }
  }

  // Start periodic connectivity check every 30 seconds
  void _startConnectivityCheck() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _testRealConnectivity();
    });
  }

  // Start periodic sync every 5 minutes when online
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_isOnline && !_isSyncing) {
        _triggerSync();
      }
    });
  }

  // Trigger sync manually
  Future<void> triggerManualSync() async {
    if (!_isOnline) {
      _setSyncError('No internet connection');
      return;
    }
    await _triggerSync();
  }

  // Internal sync trigger
  Future<void> _triggerSync() async {
    if (_isSyncing || !_isOnline) return;

    _setSyncing(true);
    _clearSyncError();

    try {
      // TODO: Implement actual sync logic with API
      // For now, simulate sync
      await Future.delayed(const Duration(seconds: 2));
      
      _lastSyncTime = DateTime.now();
      _clearSyncError();
    } catch (e) {
      _setSyncError('Sync failed: $e');
    } finally {
      _setSyncing(false);
    }
  }

  // Sync specific data types
  Future<bool> syncTransactions() async {
    if (!_isOnline) return false;

    try {
      // TODO: Implement transaction sync
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      _setSyncError('Transaction sync failed: $e');
      return false;
    }
  }

  Future<bool> syncUserData() async {
    if (!_isOnline) return false;

    try {
      // TODO: Implement user data sync
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      _setSyncError('User data sync failed: $e');
      return false;
    }
  }

  // Force offline mode (for testing)
  void setOfflineMode(bool offline) {
    _isOnline = !offline;
    notifyListeners();
  }

  // Clear sync error
  void clearSyncError() {
    _clearSyncError();
  }

  // Private helper methods
  void _setSyncing(bool syncing) {
    _isSyncing = syncing;
    notifyListeners();
  }

  void _setSyncError(String error) {
    _syncError = error;
    notifyListeners();
  }

  void _clearSyncError() {
    _syncError = null;
    notifyListeners();
  }

  // Start periodic sync
  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
       if (_isOnline) {
         syncNow();
       }
     });
  }

  // Sync now
  Future<void> syncNow() async {
    if (_isSyncing || !_isOnline) return;

    _isSyncing = true;
    notifyListeners();

    try {
      // Implementation would sync with backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate sync
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _syncError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void setAutoSync(bool enabled) {
    _autoSyncEnabled = enabled;
    if (enabled) {
      startPeriodicSync();
    } else {
      _syncTimer?.cancel();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _connectivityTimer?.cancel();
    super.dispose();
  }
}