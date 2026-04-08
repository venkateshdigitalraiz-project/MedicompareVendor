import '../datasources/leads_remote_data_source.dart';
import '../../domain/entities/lead_entity.dart';
import '../../domain/repositories/leads_repository.dart';

class LeadsRepositoryImpl implements LeadsRepository {
  final LeadsRemoteDataSource remoteDataSource;

  LeadsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<LeadsListEntity> getLeads({
    int page = 1,
    int limit = 10,
    String status = '',
    String leadStage = '',
    String search = '',
  }) async {
    return await remoteDataSource.getLeads(
      page: page,
      limit: limit,
      status: status,
      leadStage: leadStage,
      search: search,
    );
  }

  @override
  Future<LeadDetailsEntity> getLeadDetails(String id) async {
    return await remoteDataSource.getLeadDetails(id);
  }

  @override
  Future<void> updateLeadStatus(String id, String status) async {
    await remoteDataSource.updateLeadStatus(id, status);
  }
}
