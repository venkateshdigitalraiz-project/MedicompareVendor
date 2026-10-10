import 'package:equatable/equatable.dart';
import '../../domain/entities/employee_entity.dart';

abstract class EmployeeListState extends Equatable {
  const EmployeeListState();

  @override
  List<Object> get props => [];
}

class EmployeeListInitial extends EmployeeListState {}

class EmployeeListLoading extends EmployeeListState {}

class EmployeeListLoaded extends EmployeeListState {
  final List<EmployeeEntity> employees;
  final int totalStaff;
  final int activeStaff;
  final int onLeaveStaff;
  final int departments;

  const EmployeeListLoaded({
    required this.employees,
    required this.totalStaff,
    required this.activeStaff,
    required this.onLeaveStaff,
    required this.departments,
  });

  @override
  List<Object> get props => [
        employees,
        totalStaff,
        activeStaff,
        onLeaveStaff,
        departments,
      ];
}

class EmployeeListError extends EmployeeListState {
  final String message;

  const EmployeeListError({required this.message});

  @override
  List<Object> get props => [message];
}
