import '../../../../core/network/dio_client.dart';
import '../models/balance_model.dart';
import '../models/transaction_model.dart';

abstract class DashboardRemoteDataSource {
  Future<BalanceModel> getBalance();
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5});
  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<TransactionModel> createTransaction(Map<String, dynamic> transactionData);
  Future<List<Map<String, dynamic>>> getCategories();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient dioClient;

  DashboardRemoteDataSourceImpl(this.dioClient);

  @override
  Future<BalanceModel> getBalance() async {
    try {
      final response = await dioClient.get('/analytics/summary');
      return BalanceModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get balance: ${e.toString()}');
    }
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    try {
      final response = await dioClient.get(
        '/transactions/',
        queryParameters: {
          'limit': limit,
          'sort': 'created_at',
          'order': 'desc',
        },
      );

      dynamic raw = response.data;

      // If API sometimes wraps with "data", sometimes returns array
      final List<dynamic> data;
      if (raw is Map<String, dynamic> && raw.containsKey('data')) {
        data = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        data = raw;
      } else {
        data = [];
      }

      return data.isNotEmpty
          ? data.map((json) => TransactionModel.fromJson(json)).toList()
          : [];
    } catch (e) {
      throw Exception('Failed to get recent transactions: ${e.toString()}');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (category != null) {
        queryParams['category'] = category;
      }

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await dioClient.get(
        '/transactions/',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get transactions: ${e.toString()}');
    }
  }

  @override
  Future<TransactionModel> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      final response = await dioClient.post(
        '/transactions/',
        data: transactionData,
      );

      return TransactionModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create transaction: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await dioClient.get('/categories/');

      final List<dynamic> data = response.data;
      return data.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to get categories: ${e.toString()}');
    }
  }
}
