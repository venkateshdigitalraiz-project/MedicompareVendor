import 'package:http/http.dart' as http;
import 'data/datasources/leads_remote_data_source.dart';
import 'data/repositories/leads_repository_impl.dart';
import 'domain/repositories/leads_repository.dart';
import 'domain/usecases/get_leads_usecase.dart';
import 'presentation/bloc/leads_bloc.dart';

class LeadsInjection {
  static LeadsBloc provideLeadsBloc() {
    return LeadsBloc(
      getLeadsUseCase: provideGetLeadsUseCase(),
    );
  }

  static GetLeadsUseCase provideGetLeadsUseCase() {
    return GetLeadsUseCase(provideLeadsRepository());
  }

  static LeadsRepository provideLeadsRepository() {
    return LeadsRepositoryImpl(
      remoteDataSource: provideLeadsRemoteDataSource(),
    );
  }

  static LeadsRemoteDataSource provideLeadsRemoteDataSource() {
    return LeadsRemoteDataSourceImpl(client: http.Client());
  }
}
