import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/dashboard_repository.dart';

class GetCategoriesUseCase {
  final DashboardRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() async {
    return await repository.getCategories();
  }
}