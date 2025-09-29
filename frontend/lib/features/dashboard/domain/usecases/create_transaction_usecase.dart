import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/dashboard_repository.dart';

class CreateTransactionUseCase {
  final DashboardRepository repository;

  CreateTransactionUseCase(this.repository);

  Future<Either<Failure, TransactionEntity>> call(Map<String, dynamic> transactionData) async {
    return await repository.createTransaction(transactionData);
  }
}