import 'dart:convert';
import 'category.dart';

class Transaction {
  final int? id;
  final String? serverId;
  final String description;
  final double amount;
  final int categoryId;
  final TransactionType type;
  final DateTime date;
  final String? userId;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  // This field is not stored in the database, but populated from the Category table
  Category? category;

  Transaction({
    this.id,
    this.serverId,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.type,
    required this.date,
    this.userId,
    this.isSynced = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.category,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Transaction copyWith({
    int? id,
    String? serverId,
    String? description,
    double? amount,
    int? categoryId,
    TransactionType? type,
    DateTime? date,
    String? userId,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
    Category? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverId': serverId,
      'description': description,
      'amount': amount,
      'categoryId': categoryId,
      'type': type.name,
      'date': date.millisecondsSinceEpoch,
      'userId': userId,
      'isSynced': isSynced ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      serverId: map['serverId'] as String?,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['categoryId'] as int,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      userId: map['userId'] as String?,
      isSynced: (map['isSynced'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category?.name, // Send category name to API
      'type': type.name,
      'date': date.toIso8601String(),
      'userId': userId,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // This is more complex now. When we get a transaction from the server,
    // we get a category NAME. We need to find the corresponding category ID
    // in the local database. This logic should be handled in the provider/service
    // that calls this fromJson, after it has fetched the category data.
    // For now, we'll set a placeholder categoryId.
    return Transaction(
      serverId: json['_id'] as String?,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: -1, // Placeholder
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      date: DateTime.parse(json['date'] as String),
      userId: json['userId'] as String?,
      isSynced: true, // Data from server is always synced
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      // We can't create the full Category object here without more context
      category: Category(
        id: -1,
        name: json['category'] as String,
        icon: Icons.category,
        type: json['type'] as String,
      ),
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, description: $description, amount: $amount, categoryId: $categoryId, type: $type, date: $date, userId: $userId, isSynced: $isSynced)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.description == description &&
        other.amount == amount &&
        other.categoryId == categoryId &&
        other.type == type &&
        other.date == date &&
        other.userId == userId &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        categoryId.hashCode ^
        type.hashCode ^
        date.hashCode ^
        userId.hashCode ^
        isSynced.hashCode;
  }
}

enum TransactionType { income, expense }

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }

  String get name {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
    }
  }
}

class TransactionListResponse {
  final List<Transaction> transactions;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  TransactionListResponse({
    required this.transactions,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    return TransactionListResponse(
      transactions: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Transaction.fromJson(e))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': transactions.map((e) => e.toJson()).toList(),
      'totalCount': totalCount,
      'currentPage': currentPage,
      'totalPages': totalPages,
    };
  }
}