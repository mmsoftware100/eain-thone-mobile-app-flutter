import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:eainthone/models/transaction.dart';

void main() {
  group('Transaction', () {
    final date = DateTime.parse('2024-07-28 10:00:00Z');
    final transaction = Transaction(
      id: 1,
      serverId: 'server-id-123',
      description: 'Test Transaction',
      amount: 100.0,
      category: 'Test Category',
      type: TransactionType.expense,
      date: date,
      userId: 'user-id-456',
      isSynced: false,
      createdAt: date,
      updatedAt: date,
    );

    test('copyWith creates a copy with updated values', () {
      final updatedTransaction = transaction.copyWith(
        description: 'Updated Description',
        amount: 150.0,
      );

      expect(updatedTransaction.id, transaction.id);
      expect(updatedTransaction.description, 'Updated Description');
      expect(updatedTransaction.amount, 150.0);
      expect(updatedTransaction.category, transaction.category);
    });

    test('toMap returns a valid map', () {
      final map = transaction.toMap();

      expect(map['id'], 1);
      expect(map['serverId'], 'server-id-123');
      expect(map['description'], 'Test Transaction');
      expect(map['amount'], 100.0);
      expect(map['category'], 'Test Category');
      expect(map['type'], 'expense');
      expect(map['date'], date.millisecondsSinceEpoch);
      expect(map['userId'], 'user-id-456');
      expect(map['isSynced'], 0);
      expect(map['createdAt'], date.millisecondsSinceEpoch);
      expect(map['updatedAt'], date.millisecondsSinceEpoch);
    });

    test('fromMap creates a valid Transaction object', () {
      final map = {
        'id': 1,
        'serverId': 'server-id-123',
        'description': 'Test Transaction',
        'amount': 100.0,
        'category': 'Test Category',
        'type': 'expense',
        'date': date.millisecondsSinceEpoch,
        'userId': 'user-id-456',
        'isSynced': 0,
        'createdAt': date.millisecondsSinceEpoch,
        'updatedAt': date.millisecondsSinceEpoch,
      };

      final fromMapTransaction = Transaction.fromMap(map);

      expect(fromMapTransaction, equals(transaction));
    });

    test('toJson returns a valid JSON map', () {
        final jsonMap = transaction.toJson();

        expect(jsonMap['id'], 1);
        expect(jsonMap['description'], 'Test Transaction');
        expect(jsonMap['amount'], 100.0);
        expect(jsonMap['category'], 'Test Category');
        expect(jsonMap['type'], 'expense');
        expect(jsonMap['date'], date.toIso8601String());
        expect(jsonMap['userId'], 'user-id-456');
        expect(jsonMap['isSynced'], false);
        expect(jsonMap['createdAt'], date.toIso8601String());
        expect(jsonMap['updatedAt'], date.toIso8601String());
    });

    test('fromJson creates a valid Transaction object', () {
      final jsonString = json.encode(transaction.toJson());
      final fromJsonTransaction = Transaction.fromJson(jsonString);
      expect(fromJsonTransaction, equals(transaction));
    });

    test('equality operator (==) works correctly', () {
      final sameTransaction = transaction.copyWith();
      final differentTransaction = transaction.copyWith(id: 2);

      expect(transaction, equals(sameTransaction));
      expect(transaction, isNot(equals(differentTransaction)));
    });

    test('hashCode is consistent', () {
      final sameTransaction = transaction.copyWith();

      expect(transaction.hashCode, equals(sameTransaction.hashCode));
    });
  });

  group('TransactionTypeExtension', () {
    test('displayName returns correct string for income', () {
      expect(TransactionType.income.displayName, 'Income');
    });

    test('displayName returns correct string for expense', () {
      expect(TransactionType.expense.displayName, 'Expense');
    });

    test('name returns correct string for income', () {
      expect(TransactionType.income.name, 'income');
    });

    test('name returns correct string for expense', () {
      expect(TransactionType.expense.name, 'expense');
    });
  });

  group('TransactionListResponse', () {
    final date = DateTime.parse('2024-07-28 10:00:00Z');
    final transaction1 = Transaction(
      id: 1,
      description: 'Transaction 1',
      amount: 100.0,
      category: 'Category 1',
      type: TransactionType.expense,
      date: date,
    );
    final transaction2 = Transaction(
      id: 2,
      description: 'Transaction 2',
      amount: 200.0,
      category: 'Category 2',
      type: TransactionType.income,
      date: date,
    );

    test('fromJson creates a valid object', () {
      final response = TransactionListResponse(
        transactions: [transaction1, transaction2],
        totalCount: 2,
        currentPage: 1,
        totalPages: 1,
      );
      final json = response.toJson();
      final fromJson = TransactionListResponse.fromJson(json);

      expect(fromJson.transactions.length, 2);
      expect(fromJson.totalCount, 2);
      expect(fromJson.currentPage, 1);
      expect(fromJson.totalPages, 1);
    });

    test('toJson returns a valid map', () {
      final response = TransactionListResponse(
        transactions: [transaction1, transaction2],
        totalCount: 2,
        currentPage: 1,
        totalPages: 1,
      );

      final json = response.toJson();

      expect(json['data'].length, 2);
      expect(json['totalCount'], 2);
      expect(json['currentPage'], 1);
      expect(json['totalPages'], 1);
    });
  });
}