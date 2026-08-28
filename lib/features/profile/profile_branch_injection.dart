import '../../core/utils/core_injection.dart';
import 'data/data_sources/branch_service.dart';
import 'data/repositories/branch_repository_impl.dart';
import 'domain/usecases/create_branch_usecase.dart';
import 'presentation/bloc/branch_bloc.dart';

class ProfileBranchInjection {
  static BranchBloc provideBranchBloc() {
    final apiService = CoreInjection.provideApiService();
    final branchService = BranchService(apiService);
    final repository = BranchRepositoryImpl(branchService: branchService);
    final createUseCase = CreateBranchUseCase(repository);
    return BranchBloc(
      createBranchUseCase: createUseCase,
      branchRepository: repository,
    );
  }
}
