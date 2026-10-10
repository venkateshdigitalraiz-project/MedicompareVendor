import '../../core/utils/core_injection.dart';
import 'data/datasources/employee_remote_datasource.dart';
import 'data/datasources/role_remote_datasource.dart';
import 'data/repositories/employee_repository_impl.dart';
import 'data/repositories/role_repository_impl.dart';
import 'domain/repositories/employee_repository.dart';
import 'domain/repositories/role_repository.dart';
import 'domain/usecases/get_employee_list_usecase.dart';
import 'domain/usecases/get_role_list_usecase.dart';
import 'domain/usecases/get_medical_categories_usecase.dart';
import 'domain/usecases/get_employee_details_usecase.dart';
import 'domain/usecases/update_employee_usecase.dart';
import 'domain/usecases/create_employee_usecase.dart';
import 'domain/usecases/create_role_usecase.dart';
import 'domain/usecases/update_role_usecase.dart';
import 'domain/usecases/delete_role_usecase.dart';
import 'presentation/bloc/employee_list_bloc.dart';
import 'presentation/bloc/role_manage_bloc.dart';
import 'presentation/bloc/add_staff_bloc.dart';
import 'presentation/bloc/add_new_role_bloc.dart';

class RoleInjection {
  static GetEmployeeListUseCase provideGetEmployeeListUseCase() {
    final apiService = CoreInjection.provideApiService();
    final EmployeeRemoteDataSource remoteDataSource =
        EmployeeRemoteDataSourceImpl(apiService: apiService);
    final EmployeeRepository repository =
        EmployeeRepositoryImpl(remoteDataSource: remoteDataSource);
    return GetEmployeeListUseCase(repository);
  }

  static EmployeeListBloc provideEmployeeListBloc() {
    return EmployeeListBloc(getEmployeeListUseCase: provideGetEmployeeListUseCase());
  }

  static GetRoleListUseCase provideGetRoleListUseCase() {
    final apiService = CoreInjection.provideApiService();
    final RoleRemoteDataSource remoteDataSource =
        RoleRemoteDataSourceImpl(apiService: apiService);
    final RoleRepository repository =
        RoleRepositoryImpl(remoteDataSource: remoteDataSource);
    return GetRoleListUseCase(repository);
  }

  static DeleteRoleUseCase provideDeleteRoleUseCase() {
    final apiService = CoreInjection.provideApiService();
    final RoleRemoteDataSource remoteDataSource =
        RoleRemoteDataSourceImpl(apiService: apiService);
    final RoleRepository repository =
        RoleRepositoryImpl(remoteDataSource: remoteDataSource);
    return DeleteRoleUseCase(repository);
  }

  static RoleManageBloc provideRoleManageBloc() {
    return RoleManageBloc(
      getRoleListUseCase: provideGetRoleListUseCase(),
      deleteRoleUseCase: provideDeleteRoleUseCase(),
    );
  }

  static CreateRoleUseCase provideCreateRoleUseCase() {
    final apiService = CoreInjection.provideApiService();
    final RoleRemoteDataSource remoteDataSource =
        RoleRemoteDataSourceImpl(apiService: apiService);
    final RoleRepository repository =
        RoleRepositoryImpl(remoteDataSource: remoteDataSource);
    return CreateRoleUseCase(repository);
  }

  static UpdateRoleUseCase provideUpdateRoleUseCase() {
    final apiService = CoreInjection.provideApiService();
    final RoleRemoteDataSource remoteDataSource =
        RoleRemoteDataSourceImpl(apiService: apiService);
    final RoleRepository repository =
        RoleRepositoryImpl(remoteDataSource: remoteDataSource);
    return UpdateRoleUseCase(repository);
  }

  static AddNewRoleBloc provideAddNewRoleBloc() {
    return AddNewRoleBloc(
      createRoleUseCase: provideCreateRoleUseCase(),
      updateRoleUseCase: provideUpdateRoleUseCase(),
    );
  }

  static GetMedicalCategoriesUseCase provideGetMedicalCategoriesUseCase() {
    final apiService = CoreInjection.provideApiService();
    final RoleRemoteDataSource remoteDataSource =
        RoleRemoteDataSourceImpl(apiService: apiService);
    final RoleRepository repository =
        RoleRepositoryImpl(remoteDataSource: remoteDataSource);
    return GetMedicalCategoriesUseCase(repository);
  }

  static CreateEmployeeUseCase provideCreateEmployeeUseCase() {
    final apiService = CoreInjection.provideApiService();
    final EmployeeRemoteDataSource remoteDataSource =
        EmployeeRemoteDataSourceImpl(apiService: apiService);
    final EmployeeRepository repository =
        EmployeeRepositoryImpl(remoteDataSource: remoteDataSource);
    return CreateEmployeeUseCase(repository);
  }

  static GetEmployeeDetailsUseCase provideGetEmployeeDetailsUseCase() {
    final apiService = CoreInjection.provideApiService();
    final EmployeeRemoteDataSource remoteDataSource =
        EmployeeRemoteDataSourceImpl(apiService: apiService);
    final EmployeeRepository repository =
        EmployeeRepositoryImpl(remoteDataSource: remoteDataSource);
    return GetEmployeeDetailsUseCase(repository);
  }

  static UpdateEmployeeUseCase provideUpdateEmployeeUseCase() {
    final apiService = CoreInjection.provideApiService();
    final EmployeeRemoteDataSource remoteDataSource =
        EmployeeRemoteDataSourceImpl(apiService: apiService);
    final EmployeeRepository repository =
        EmployeeRepositoryImpl(remoteDataSource: remoteDataSource);
    return UpdateEmployeeUseCase(repository);
  }

  static AddStaffBloc provideAddStaffBloc() {
    return AddStaffBloc(
      getRoleListUseCase: provideGetRoleListUseCase(),
      getMedicalCategoriesUseCase: provideGetMedicalCategoriesUseCase(),
      createEmployeeUseCase: provideCreateEmployeeUseCase(),
      getEmployeeDetailsUseCase: provideGetEmployeeDetailsUseCase(),
      updateEmployeeUseCase: provideUpdateEmployeeUseCase(),
    );
  }
}
