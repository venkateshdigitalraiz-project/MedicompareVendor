import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_role_list_usecase.dart';
import 'role_manage_event.dart';
import 'role_manage_state.dart';

import '../../domain/usecases/delete_role_usecase.dart';

class RoleManageBloc extends Bloc<RoleManageEvent, RoleManageState> {
  final GetRoleListUseCase getRoleListUseCase;
  final DeleteRoleUseCase deleteRoleUseCase;

  RoleManageBloc({
    required this.getRoleListUseCase,
    required this.deleteRoleUseCase,
  }) : super(RoleManageInitial()) {
    on<LoadRoleManageData>(_onLoadRoleManageData);
    on<DeleteRole>(_onDeleteRole);
  }

  void _onLoadRoleManageData(
      LoadRoleManageData event, Emitter<RoleManageState> emit) async {
    emit(RoleManageLoading());
    final result = await getRoleListUseCase();

    result.fold(
      (failure) => emit(RoleManageError(message: failure.message)),
      (roles) {
        int activeCount = roles.where((r) => r.status.toLowerCase() == 'active').length;
        int inactiveCount = roles.where((r) => r.status.toLowerCase() != 'active').length;
        int totalStaffCount = roles.fold(0, (sum, item) => sum + item.staffCount);

        emit(RoleManageLoaded(
          roles: roles,
          totalRoles: roles.length,
          activeRoles: activeCount,
          inactiveRoles: inactiveCount,
          totalStaff: totalStaffCount,
        ));
      },
    );
  }

  void _onDeleteRole(DeleteRole event, Emitter<RoleManageState> emit) async {
    final result = await deleteRoleUseCase(event.roleId);
    
    result.fold(
      (failure) {
        // Here you might want to emit an error state or show a snackbar.
        // For now, let's just reload the data or emit error.
        emit(RoleManageError(message: failure.message));
      },
      (_) {
        // Reload data after successful deletion
        add(LoadRoleManageData());
      },
    );
  }
}
