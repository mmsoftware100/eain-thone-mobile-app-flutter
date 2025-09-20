import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/transaction.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  static const String baseUrl =
      'https://eain-thone-backend-express-typescript.onrender.com'; // Replace with actual API URL
  // static const String baseUrl = 'https://api.example.com'; // Replace with actual API URL

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
  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['user']);
        setAuthToken(response.data['token']);
        return ApiResponse.success(user);
      } else {
        return ApiResponse.error('Login failed');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<User>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 201) {
        final user = User.fromJson(response.data['user']);
        setAuthToken(response.data['token']);
        return ApiResponse.success(user);
      } else {
        return ApiResponse.error('Registration failed');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      await _dio.post('/auth/logout');
      clearAuthToken();
      return ApiResponse.success(null);
    } on DioException catch (e) {
      clearAuthToken(); // Clear token even if logout fails
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      clearAuthToken();
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // Transaction endpoints
  Future<ApiResponse<List<Transaction>>> getTransactions() async {
    try {
      final response = await _dio.get('/transactions');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['transactions'];
        final transactions = data
            .map((json) => Transaction.fromJson(json))
            .toList();
        return ApiResponse.success(transactions);
      } else {
        return ApiResponse.error('Failed to fetch transactions');
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

      if (response.statusCode == 201) {
        final createdTransaction = Transaction.fromJson(
          response.data['transaction'],
        );
        return ApiResponse.success(createdTransaction);
      } else {
        return ApiResponse.error('Failed to create transaction');
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

      if (response.statusCode == 200) {
        final updatedTransaction = Transaction.fromJson(
          response.data['transaction'],
        );
        return ApiResponse.success(updatedTransaction);
      } else {
        return ApiResponse.error('Failed to update transaction');
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

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to delete transaction');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // Sync endpoints
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

  // User profile endpoints
  Future<ApiResponse<User>> getUserProfile() async {
    try {
      final response = await _dio.get('/user/profile');

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['user']);
        return ApiResponse.success(user);
      } else {
        return ApiResponse.error('Failed to fetch user profile');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<User>> updateUserProfile(String name, String email) async {
    try {
      final response = await _dio.put(
        '/user/profile',
        data: {'name': name, 'email': email},
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['user']);
        return ApiResponse.success(user);
      } else {
        return ApiResponse.error('Failed to update profile');
      }
    } on DioException catch (e) {
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
