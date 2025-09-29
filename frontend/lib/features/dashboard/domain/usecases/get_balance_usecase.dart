import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/balance_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetBalanceUseCase {
  final DashboardRepository repository;

  GetBalanceUseCase(this.repository);

  Future<Either<Failure, BalanceEntity>> call() async {
    return await repository.getBalance();
  }
}