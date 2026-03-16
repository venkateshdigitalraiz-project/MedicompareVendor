import '../entities/lead_entity.dart';
import '../repositories/leads_repository.dart';

class GetLeadsUseCase {
  final LeadsRepository repository;

  GetLeadsUseCase(this.repository);

  Future<LeadsListEntity> call({
    int page = 1,
    int limit = 10,
    String status = '',
    String leadStage = '',
    String search = '',
  }) async {
    return await repository.getLeads(
      page: page,
      limit: limit,
      status: status,
      leadStage: leadStage,
      search: search,
    );
  }
}
