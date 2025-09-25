import 'dart:convert';

class Transaction {
  final int? id;
  final String? serverId;
  final String description;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime date;
  final String? userId;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    this.id,
    this.serverId,
    required this.description,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.userId,
    this.isSynced = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Transaction copyWith({
    int? id,
    String? serverId,
    String? description,
    double? amount,
    String? category,
    TransactionType? type,
    DateTime? date,
    String? userId,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverId': serverId,
      'description': description,
      'amount': amount,
      'category': category,
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
      category: map['category'] as String,
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
      'category': category,
      'type': type.name,
      'date': date.toIso8601String(),
      'userId': userId,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Transaction.fromJson(String source) {
    final map = json.decode(source) as Map<String, dynamic>;
    return Transaction.fromMap(map);
  }

  @override
  String toString() {
    return 'Transaction(id: $id, description: $description, amount: $amount, category: $category, type: $type, date: $date, userId: $userId, isSynced: $isSynced)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.description == description &&
        other.amount == amount &&
        other.category == category &&
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
        category.hashCode ^
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