// Sync models for API responses

class BulkSyncResponse {
  final int created;
  final int updated;
  final List<BulkSyncError> errors;

  BulkSyncResponse({
    required this.created,
    required this.updated,
    required this.errors,
  });

  factory BulkSyncResponse.fromJson(Map<String, dynamic> json) {
    return BulkSyncResponse(
      created: json['created'] ?? 0,
      updated: json['updated'] ?? 0,
      errors: (json['errors'] as List<dynamic>? ?? [])
          .map((e) => BulkSyncError.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created': created,
      'updated': updated,
      'errors': errors.map((e) => e.toJson()).toList(),
    };
  }
}

class BulkSyncError {
  final int index;
  final String error;

  BulkSyncError({
    required this.index,
    required this.error,
  });

  factory BulkSyncError.fromJson(Map<String, dynamic> json) {
    return BulkSyncError(
      index: json['index'] ?? 0,
      error: json['error'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'error': error,
    };
  }
}

class SyncStatus {
  final int totalTransactions;
  final int syncedTransactions;
  final int unsyncedTransactions;
  final DateTime? lastSyncAt;

  SyncStatus({
    required this.totalTransactions,
    required this.syncedTransactions,
    required this.unsyncedTransactions,
    this.lastSyncAt,
  });

  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      totalTransactions: json['totalTransactions'] ?? 0,
      syncedTransactions: json['syncedTransactions'] ?? 0,
      unsyncedTransactions: json['unsyncedTransactions'] ?? 0,
      lastSyncAt: json['lastSyncAt'] != null 
          ? DateTime.parse(json['lastSyncAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTransactions': totalTransactions,
      'syncedTransactions': syncedTransactions,
      'unsyncedTransactions': unsyncedTransactions,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
    };
  }
}