import 'package:equatable/equatable.dart';

abstract class RoleManageEvent extends Equatable {
  const RoleManageEvent();

  @override
  List<Object> get props => [];
}

class LoadRoleManageData extends RoleManageEvent {}

class DeleteRole extends RoleManageEvent {
  final String roleId;
  const DeleteRole(this.roleId);

  @override
  List<Object> get props => [roleId];
}
