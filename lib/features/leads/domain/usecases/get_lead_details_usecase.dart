import '../entities/lead_entity.dart';
import '../repositories/leads_repository.dart';

class GetLeadDetailsUseCase {
  final LeadsRepository repository;

  GetLeadDetailsUseCase(this.repository);

  Future<LeadDetailsEntity> call(String id) async {
    return await repository.getLeadDetails(id);
  }
}
