import 'package:equatable/equatable.dart';

abstract class AddStaffEvent extends Equatable {
  const AddStaffEvent();

  @override
  List<Object> get props => [];
}

class LoadAddStaffFormData extends AddStaffEvent {
  final String? employeeId;

  const LoadAddStaffFormData({this.employeeId});

  @override
  List<Object> get props => [employeeId ?? ''];
}

class SubmitAddStaff extends AddStaffEvent {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String address;
  final String role;
  final String department;
  final String position;
  final String hireDate;
  final String experience;
  final List<String> languages;
  final String shift;
  final String? employeeId;

  const SubmitAddStaff({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.address,
    required this.role,
    required this.department,
    required this.position,
    required this.hireDate,
    required this.experience,
    required this.languages,
    required this.shift,
    this.employeeId,
  });

  @override
  List<Object> get props => [
        fullName,
        email,
        phone,
        password,
        address,
        role,
        department,
        position,
        hireDate,
        experience,
        languages,
        shift,
        employeeId ?? '',
      ];
}
