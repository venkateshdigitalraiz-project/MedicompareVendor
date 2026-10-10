import 'package:equatable/equatable.dart';
import '../../domain/entities/role_entity.dart';

abstract class RoleManageState extends Equatable {
  const RoleManageState();

  @override
  List<Object> get props => [];
}

class RoleManageInitial extends RoleManageState {}

class RoleManageLoading extends RoleManageState {}

class RoleManageLoaded extends RoleManageState {
  final List<RoleEntity> roles;
  final int totalRoles;
  final int activeRoles;
  final int inactiveRoles;
  final int totalStaff;

  const RoleManageLoaded({
    required this.roles,
    required this.totalRoles,
    required this.activeRoles,
    required this.inactiveRoles,
    required this.totalStaff,
  });

  @override
  List<Object> get props => [roles, totalRoles, activeRoles, inactiveRoles, totalStaff];
}

class RoleManageError extends RoleManageState {
  final String message;

  const RoleManageError({required this.message});

  @override
  List<Object> get props => [message];
}
