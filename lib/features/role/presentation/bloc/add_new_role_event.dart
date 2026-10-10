import 'package:equatable/equatable.dart';

abstract class AddNewRoleEvent extends Equatable {
  const AddNewRoleEvent();

  @override
  List<Object> get props => [];
}

class TogglePermission extends AddNewRoleEvent {
  final String category;
  final String action;
  final bool isSelected;

  const TogglePermission(this.category, this.action, this.isSelected);

  @override
  List<Object> get props => [category, action, isSelected];
}

class SelectAllPermissions extends AddNewRoleEvent {
  final List<String> allCategories;
  final List<String> allActions;

  const SelectAllPermissions(this.allCategories, this.allActions);

  @override
  List<Object> get props => [allCategories, allActions];
}

class ClearAllPermissions extends AddNewRoleEvent {}

class InitializePermissions extends AddNewRoleEvent {
  final Map<String, Set<String>> initialPermissions;
  const InitializePermissions(this.initialPermissions);

  @override
  List<Object> get props => [initialPermissions];
}

class SubmitNewRole extends AddNewRoleEvent {
  final String roleName;
  final String colorTheme;
  final String? roleId;

  const SubmitNewRole({
    required this.roleName,
    required this.colorTheme,
    this.roleId,
  });

  @override
  List<Object> get props => [roleName, colorTheme, roleId ?? ''];
}
