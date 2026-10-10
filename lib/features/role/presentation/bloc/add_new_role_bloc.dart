import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_new_role_event.dart';
import 'add_new_role_state.dart';

import '../../domain/usecases/create_role_usecase.dart';
import '../../domain/usecases/update_role_usecase.dart';
import '../../../../core/error/failures.dart';

class AddNewRoleBloc extends Bloc<AddNewRoleEvent, AddNewRoleState> {
  final CreateRoleUseCase createRoleUseCase;
  final UpdateRoleUseCase updateRoleUseCase;

  AddNewRoleBloc({
    required this.createRoleUseCase,
    required this.updateRoleUseCase,
  }) : super(AddNewRoleState.initial()) {
    on<TogglePermission>(_onTogglePermission);
    on<SelectAllPermissions>(_onSelectAllPermissions);
    on<ClearAllPermissions>(_onClearAllPermissions);
    on<SubmitNewRole>(_onSubmitNewRole);
    on<InitializePermissions>(_onInitializePermissions);
  }

  void _onTogglePermission(
      TogglePermission event, Emitter<AddNewRoleState> emit) {
    final Map<String, Set<String>> newPermissions = Map.from(state.permissions);

    if (!newPermissions.containsKey(event.category)) {
      newPermissions[event.category] = {};
    }

    final categorySet = Set<String>.from(newPermissions[event.category]!);

    if (event.isSelected) {
      categorySet.add(event.action);
    } else {
      categorySet.remove(event.action);
    }

    newPermissions[event.category] = categorySet;
    emit(state.copyWith(permissions: newPermissions));
  }

  void _onSelectAllPermissions(
      SelectAllPermissions event, Emitter<AddNewRoleState> emit) {
    final Map<String, Set<String>> newPermissions = {};
    for (var cat in event.allCategories) {
      newPermissions[cat] = Set<String>.from(
        event.allActions.where((action) => action.toLowerCase() != 'delete'),
      );
    }
    emit(state.copyWith(permissions: newPermissions));
  }

  void _onClearAllPermissions(
      ClearAllPermissions event, Emitter<AddNewRoleState> emit) {
    emit(state.copyWith(permissions: {}));
  }

  void _onInitializePermissions(
      InitializePermissions event, Emitter<AddNewRoleState> emit) {
    emit(state.copyWith(permissions: event.initialPermissions));
  }

  void _onSubmitNewRole(
      SubmitNewRole event, Emitter<AddNewRoleState> emit) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      // Create permissions payload
      final List<Map<String, dynamic>> permissionList = [];
      final allCategories = state.permissions.keys.toList();

      // If a category was not interacted with, it might not be in state.permissions.
      // But we should send all categories. The UI has a fixed list of categories.
      // We can get them from the event or just build from what's in state + default ones if needed.
      // Actually, let's just send what we have in state, plus we can extract categories from somewhere else,
      // but let's assume we map what's selected, or we map a standard list.
      // To be safe, we'll map what is in state.permissions, and if it's empty, we send empty.
      // Wait, the API sample shows all modules. Let's list the known modules here.
      final knownModules = [
        'staff',
        'reports',
        'homecare',
        'medicine',
        'medicaltreatment',
        'ambulanceservice',
        'medicalequipment',
        'diagnostics',
        'labtests',
        'nursingcare',
        'coupons',
        'dentalservice',
        'surgeries'
      ];

      for (String module in knownModules) {
        // Find if we have selections for this module (case insensitive match from category)
        final categoryKey = state.permissions.keys
            .firstWhere((k) => k.toLowerCase() == module, orElse: () => '');

        final selectedActions = categoryKey.isNotEmpty
            ? state.permissions[categoryKey]!
            : <String>{};

        permissionList.add({
          "module": module,
          "status": "active",
          "actions": [
            {"key": "view", "enabled": selectedActions.contains("View")},
            {"key": "add", "enabled": selectedActions.contains("Add")},
            {"key": "edit", "enabled": selectedActions.contains("Edit")},
            {"key": "delete", "enabled": selectedActions.contains("Delete")},
            {"key": "assign", "enabled": false}
          ]
        });
      }

      String colorTheme =
          "bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400";
      if (event.colorTheme.toLowerCase() == 'red') {
        colorTheme =
            "bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400";
      } else if (event.colorTheme.toLowerCase() == 'green') {
        colorTheme =
            "bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400";
      }

      final payload = {
        "name": event.roleName,
        "permission": permissionList,
        "color": colorTheme,
        "status": "active"
      };

      Either<Failure, void> result;
      if (event.roleId != null && event.roleId!.isNotEmpty) {
        result = await updateRoleUseCase(event.roleId!, payload);
      } else {
        result = await createRoleUseCase(payload);
      }

      result.fold(
        (failure) =>
            emit(state.copyWith(isSubmitting: false, error: failure.message)),
        (_) => emit(state.copyWith(isSubmitting: false, isSuccess: true)),
      );
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }
}
