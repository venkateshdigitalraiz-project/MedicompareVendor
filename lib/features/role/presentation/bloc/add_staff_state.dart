import 'package:equatable/equatable.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/entities/medical_category_entity.dart';
import '../../domain/entities/employee_entity.dart';

abstract class AddStaffState extends Equatable {
  const AddStaffState();

  @override
  List<Object?> get props => [];
}

class AddStaffInitial extends AddStaffState {}

class AddStaffFormLoading extends AddStaffState {}

class AddStaffFormLoaded extends AddStaffState {
  final List<RoleEntity> roles;
  final List<MedicalCategoryEntity> categories;
  final EmployeeEntity? employee;

  const AddStaffFormLoaded({
    required this.roles,
    required this.categories,
    this.employee,
  });

  @override
  List<Object?> get props => [roles, categories, employee];
}

class AddStaffLoading extends AddStaffState {}

class AddStaffSuccess extends AddStaffState {}

class AddStaffFailure extends AddStaffState {
  final String error;

  const AddStaffFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
