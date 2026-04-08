import '../repositories/leads_repository.dart';

class UpdateLeadStatusUseCase {
  final LeadsRepository repository;

  UpdateLeadStatusUseCase({required this.repository});

  Future<void> call(String id, String status) async {
    return await repository.updateLeadStatus(id, status);
  }
}
