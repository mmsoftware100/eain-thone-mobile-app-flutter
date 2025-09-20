import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/analytics.dart';
import '../models/sync.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  static const String baseUrl =
      'https://eain-thone-backend-express-typescript.onrender.com/api/v1'; // Real API URL

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Handle common errors
          if (error.response?.statusCode == 401) {
            // Token expired, handle logout
          }
          handler.next(error);
        },
      ),
    );
  }

  // Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Authentication endpoints
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse.success(response.data['data']);
      } else {
        // Check for error field first, then message field
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Login failed';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        // Check for error field first, then message field in error response
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> register(String email, String password, String name) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
        return ApiResponse.success(response.data['data']);
      } else {
        // Check for error field first, then message field
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Registration failed';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        // Check for error field first, then message field in error response
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _dio.post('/auth/logout');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse.success(null);
      } else {
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Logout failed';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<void>> refreshToken() async {
    try {
      final response = await _dio.post('/auth/refresh');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Update the token if provided in response
        if (response.data['data']?['token'] != null) {
          setAuthToken(response.data['data']['token']);
        }
        return ApiResponse.success(null);
      } else {
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Token refresh failed';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // Transaction endpoints
  Future<ApiResponse<TransactionListResponse>> getTransactions({
    int page = 1,
    int limit = 10,
    String? category,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (category != null) queryParams['category'] = category;
      if (type != null) queryParams['type'] = type;

      final response = await _dio.get(
        '/transactions',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final listResponse = TransactionListResponse.fromJson(response.data);
        return ApiResponse.success(listResponse);
      } else {
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Failed to fetch transactions';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Transaction>> getTransactionById(String id) async {
    try {
      final response = await _dio.get('/transactions/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final transaction = Transaction.fromJson(response.data['data']);
        return ApiResponse.success(transaction);
      } else {
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Transaction not found';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<List<Transaction>>> getTransactionsSimple() async {
    try {
      final response = await _dio.get('/transactions');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['transactions'];
        final transactions = data
            .map((json) => Transaction.fromJson(json))
            .toList();
        return ApiResponse.success(transactions);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to fetch transactions');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Transaction>> createTransaction(
    Transaction transaction,
  ) async {
    try {
      final response = await _dio.post(
        '/transactions',
        data: transaction.toJson(),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final createdTransaction = Transaction.fromJson(
          response.data['data']['transaction'],
        );
        return ApiResponse.success(createdTransaction);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to create transaction');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Transaction>> updateTransaction(
    Transaction transaction,
  ) async {
    try {
      final response = await _dio.put(
        '/transactions/${transaction.serverId}',
        data: transaction.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final updatedTransaction = Transaction.fromJson(
          response.data['data']['transaction'],
        );
        return ApiResponse.success(updatedTransaction);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to update transaction');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<void>> deleteTransaction(String serverId) async {
    try {
      final response = await _dio.delete('/transactions/$serverId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to delete transaction');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // Sync endpoints
  Future<ApiResponse<BulkSyncResponse>> bulkSyncTransactions(
    List<Transaction> transactions,
  ) async {
    try {
      final response = await _dio.post(
        '/sync/bulk',
        data: {
          'transactions': transactions.map((t) => t.toJson()).toList(),
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final bulkResponse = BulkSyncResponse.fromJson(response.data['data']);
        return ApiResponse.success(bulkResponse);
      } else {
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Bulk sync failed';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<List<Transaction>>> getUnsyncedTransactions() async {
    try {
      final response = await _dio.get('/sync/unsynced');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final transactions = data
            .map((json) => Transaction.fromJson(json))
            .toList();
        return ApiResponse.success(transactions);
      } else {
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Failed to fetch unsynced transactions';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<void>> markTransactionsSynced(
    List<String> transactionIds,
  ) async {
    try {
      final response = await _dio.post(
        '/sync/mark-synced',
        data: {'transactionIds': transactionIds},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse.success(null);
      } else {
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Failed to mark transactions as synced';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<SyncStatus>> getSyncStatus() async {
    try {
      final response = await _dio.get('/sync/status');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final status = SyncStatus.fromJson(response.data['data']);
        return ApiResponse.success(status);
      } else {
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Failed to fetch sync status';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<SyncResponse>> syncTransactions(
    List<Transaction> localTransactions,
  ) async {
    try {
      final response = await _dio.post(
        '/sync/transactions',
        data: {
          'transactions': localTransactions.map((t) => t.toJson()).toList(),
        },
      );

      if (response.statusCode == 200) {
        final syncResponse = SyncResponse.fromJson(response.data);
        return ApiResponse.success(syncResponse);
      } else {
        return ApiResponse.error('Sync failed');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // Analytics endpoints
  Future<ApiResponse<FinancialSummary>> getFinancialSummary() async {
    try {
      final response = await _dio.get('/analytics/summary');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final summary = FinancialSummary.fromJson(response.data['data']);
        return ApiResponse.success(summary);
      } else {
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Failed to fetch financial summary';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<List<CategoryBreakdownItem>>> getCategoryBreakdown() async {
    try {
      final response = await _dio.get('/analytics/category-breakdown');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final breakdown = data
            .map((json) => CategoryBreakdownItem.fromJson(json))
            .toList();
        return ApiResponse.success(breakdown);
      } else {
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Failed to fetch category breakdown';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<List<MonthlyTrendItem>>> getMonthlyTrends() async {
    try {
      final response = await _dio.get('/analytics/monthly-trends');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final trends = data
            .map((json) => MonthlyTrendItem.fromJson(json))
            .toList();
        return ApiResponse.success(trends);
      } else {
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Failed to fetch monthly trends';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // User profile endpoints
  Future<ApiResponse<User>> getUserProfile() async {
    try {
      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final user = User.fromJson(response.data['data']['user']);
        return ApiResponse.success(user);
      } else {
        // Handle error response from server
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Failed to fetch user profile';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      // Handle HTTP errors and extract server error messages
      if (e.response?.data != null) {
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<User>> updateUserProfile(String name, String email) async {
    try {
      final response = await _dio.put(
        '/auth/me',
        data: {'name': name, 'email': email},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final user = User.fromJson(response.data['data']['user']);
        return ApiResponse.success(user);
      } else {
        // Handle error response from server
        final errorMessage = response.data['error'] ?? 
                           response.data['message'] ?? 
                           'Failed to update profile';
        return ApiResponse.error(errorMessage);
      }
    } on DioException catch (e) {
      // Handle HTTP errors and extract server error messages
      if (e.response?.data != null) {
        final errorMessage = e.response!.data['error'] ?? 
                           e.response!.data['message'] ?? 
                           _handleDioError(e);
        return ApiResponse.error(errorMessage);
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // Error handling
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Server error';
        return 'Server error ($statusCode): $message';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'Network error: ${error.message}';
    }
  }
}

// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse.success(this.data) : success = true, error = null;
  ApiResponse.error(this.error) : success = false, data = null;
}

// Sync response model
class SyncResponse {
  final List<Transaction> serverTransactions;
  final List<String> conflictIds;
  final DateTime lastSyncTime;

  SyncResponse({
    required this.serverTransactions,
    required this.conflictIds,
    required this.lastSyncTime,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) {
    return SyncResponse(
      serverTransactions: (json['serverTransactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
      conflictIds: List<String>.from(json['conflictIds'] ?? []),
      lastSyncTime: DateTime.parse(json['lastSyncTime']),
    );
  }
}
