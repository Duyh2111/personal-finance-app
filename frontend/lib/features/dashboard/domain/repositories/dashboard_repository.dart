import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/balance_entity.dart';
import '../entities/transaction_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, BalanceEntity>> getBalance();
  Future<Either<Failure, List<TransactionEntity>>> getRecentTransactions({int limit = 5});
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    int page = 1,
    int limit = 20,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, TransactionEntity>> createTransaction(Map<String, dynamic> transactionData);
  Future<Either<Failure, List<Map<String, dynamic>>>> getCategories();
}