import '../../core/utils/core_injection.dart';
import 'data/datasources/leads_remote_data_source.dart';
import 'data/repositories/leads_repository_impl.dart';
import 'domain/repositories/leads_repository.dart';
import 'domain/usecases/get_lead_details_usecase.dart';
import 'domain/usecases/get_leads_usecase.dart';
import 'domain/usecases/update_lead_status_usecase.dart';
import 'presentation/bloc/leads_bloc.dart';

class LeadsInjection {
  static LeadsBloc provideLeadsBloc() {
    return LeadsBloc(
      getLeadsUseCase: provideGetLeadsUseCase(),
      getLeadDetailsUseCase: provideGetLeadDetailsUseCase(),
      updateLeadStatusUseCase: provideUpdateLeadStatusUseCase(),
    );
  }

  static GetLeadsUseCase provideGetLeadsUseCase() {
    return GetLeadsUseCase(provideLeadsRepository());
  }

  static GetLeadDetailsUseCase provideGetLeadDetailsUseCase() {
    return GetLeadDetailsUseCase(provideLeadsRepository());
  }

  static UpdateLeadStatusUseCase provideUpdateLeadStatusUseCase() {
    return UpdateLeadStatusUseCase(repository: provideLeadsRepository());
  }

  static LeadsRepository provideLeadsRepository() {
    return LeadsRepositoryImpl(
      remoteDataSource: provideLeadsRemoteDataSource(),
    );
  }

  static LeadsRemoteDataSource provideLeadsRemoteDataSource() {
    return LeadsRemoteDataSourceImpl(
      apiService: CoreInjection.provideApiService(),
    );
  }
}
