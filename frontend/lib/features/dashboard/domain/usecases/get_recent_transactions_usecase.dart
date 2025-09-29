import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetRecentTransactionsUseCase {
  final DashboardRepository repository;

  GetRecentTransactionsUseCase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call({int limit = 10}) async {
    return await repository.getRecentTransactions(limit: limit);
  }
}