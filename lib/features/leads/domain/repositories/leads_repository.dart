import '../entities/lead_entity.dart';

abstract class LeadsRepository {
  Future<LeadsListEntity> getLeads({
    int page = 1,
    int limit = 10,
    String status = '',
    String leadStage = '',
    String search = '',
  });
  Future<LeadDetailsEntity> getLeadDetails(String id);
}
