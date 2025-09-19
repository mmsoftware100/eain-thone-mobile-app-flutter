import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class SyncProvider with ChangeNotifier {
  bool _isOnline = false;
  bool _isSyncing = false;
  bool _autoSyncEnabled = true;
  String? _syncError;
  DateTime? _lastSyncTime;
  Timer? _syncTimer;

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

  // Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectivity(connectivityResult);

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen(_updateConnectivity);

    // Start periodic sync when online
    _startPeriodicSync();
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.any((result) => 
      result == ConnectivityResult.mobile || 
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet
    );
    
    if (!wasOnline && _isOnline) {
      // Just came online, trigger sync
      _triggerSync();
    }
    
    notifyListeners();
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
    super.dispose();
  }
}