import '../entities/dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardUseCase {
  final DashboardRepository repository;

  GetDashboardUseCase({required this.repository});

  Future<DashboardEntity> call() async {
    return await repository.getDashboard();
  }
}
