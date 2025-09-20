// Analytics models for API responses

class FinancialSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int transactionCount;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.transactionCount,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      totalIncome: (json['totalIncome'] ?? 0).toDouble(),
      totalExpenses: (json['totalExpenses'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      transactionCount: json['transactionCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': balance,
      'transactionCount': transactionCount,
    };
  }
}

class CategoryBreakdownItem {
  final String category;
  final double total;
  final int count;

  CategoryBreakdownItem({
    required this.category,
    required this.total,
    required this.count,
  });

  factory CategoryBreakdownItem.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownItem(
      category: json['_id'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': category,
      'total': total,
      'count': count,
    };
  }
}

class MonthlyTrendItem {
  final int year;
  final int month;
  final double income;
  final double expenses;

  MonthlyTrendItem({
    required this.year,
    required this.month,
    required this.income,
    required this.expenses,
  });

  factory MonthlyTrendItem.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] ?? {};
    return MonthlyTrendItem(
      year: id['year'] ?? 0,
      month: id['month'] ?? 0,
      income: (json['income'] ?? 0).toDouble(),
      expenses: (json['expenses'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': {
        'year': year,
        'month': month,
      },
      'income': income,
      'expenses': expenses,
    };
  }
}