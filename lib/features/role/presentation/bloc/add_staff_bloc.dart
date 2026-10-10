import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import 'add_staff_event.dart';
import 'add_staff_state.dart';

import '../../domain/usecases/get_role_list_usecase.dart';
import '../../domain/usecases/get_medical_categories_usecase.dart';
import '../../domain/usecases/create_employee_usecase.dart';
import '../../domain/usecases/get_employee_details_usecase.dart';
import '../../domain/usecases/update_employee_usecase.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/entities/medical_category_entity.dart';
import '../../domain/entities/employee_entity.dart';

class AddStaffBloc extends Bloc<AddStaffEvent, AddStaffState> {
  final GetRoleListUseCase getRoleListUseCase;
  final GetMedicalCategoriesUseCase getMedicalCategoriesUseCase;
  final CreateEmployeeUseCase createEmployeeUseCase;
  final GetEmployeeDetailsUseCase getEmployeeDetailsUseCase;
  final UpdateEmployeeUseCase updateEmployeeUseCase;
  List<RoleEntity> _roles = [];
  List<MedicalCategoryEntity> _categories = [];

  AddStaffBloc({
    required this.getRoleListUseCase,
    required this.getMedicalCategoriesUseCase,
    required this.createEmployeeUseCase,
    required this.getEmployeeDetailsUseCase,
    required this.updateEmployeeUseCase,
  }) : super(AddStaffInitial()) {
    on<LoadAddStaffFormData>(_onLoadFormData);
    on<SubmitAddStaff>(_onSubmitAddStaff);
  }

  void _onLoadFormData(
      LoadAddStaffFormData event, Emitter<AddStaffState> emit) async {
    emit(AddStaffFormLoading());

    final results = await Future.wait([
      getRoleListUseCase(status: 'active'),
      getMedicalCategoriesUseCase(),
    ]);

    final roleResult = results[0] as Either<Failure, List<RoleEntity>>;
    final categoryResult =
        results[1] as Either<Failure, List<MedicalCategoryEntity>>;

    String? errorMessage;
    
    roleResult.fold(
      (failure) => errorMessage = failure.message,
      (roles) => _roles = roles,
    );

    if (errorMessage != null) {
      emit(AddStaffFailure(error: errorMessage!));
      return;
    }

    categoryResult.fold(
      (failure) => errorMessage = failure.message,
      (categories) => _categories = categories,
    );

    if (errorMessage != null) {
      emit(AddStaffFailure(error: errorMessage!));
      return;
    }

    EmployeeEntity? employee;
    if (event.employeeId != null) {
      final employeeResult = await getEmployeeDetailsUseCase(event.employeeId!);
      employeeResult.fold(
        (failure) => errorMessage = failure.message,
        (emp) => employee = emp,
      );
      if (errorMessage != null) {
        emit(AddStaffFailure(error: errorMessage!));
        return;
      }
    }

    emit(AddStaffFormLoaded(
        roles: _roles, categories: _categories, employee: employee));
  }

  void _onSubmitAddStaff(
      SubmitAddStaff event, Emitter<AddStaffState> emit) async {
    emit(AddStaffLoading());
    try {
      // Find Role ID from name
      String roleId = '';
      try {
        roleId = _roles.firstWhere((element) => element.name == event.role).id;
      } catch (e) {
        // Fallback to name if ID not found, but API expects ID
        roleId = event.role;
      }

      // Find Department ID from name
      String departmentId = '';
      try {
        departmentId = _categories
            .firstWhere((element) => element.name == event.department)
            .id;
      } catch (e) {
        departmentId = event.department;
      }

      final Map<String, dynamic> body = {
        "name": event.fullName,
        "email": event.email,
        "phone": event.phone,
        "password": event.password,
        "role": roleId,
        "department": departmentId,
        "position": event.position,
        "address": event.address,
        "skills": [],
        "certifications": [],
        "languages": event.languages,
        "hireDate": event.hireDate, // Expected format YYYY-MM-DD
        "experience": event.experience,
        "shift": event.shift.toLowerCase(),
        "availability": {
          "monday": true,
          "tuesday": true,
          "wednesday": true,
          "thursday": true,
          "friday": true,
          "saturday": false,
          "sunday": false
        }
      };

      if (event.employeeId != null) {
        // Edit mode
        final result = await updateEmployeeUseCase(event.employeeId!, body);
        result.fold(
          (failure) {
            emit(AddStaffFailure(error: failure.message));
          },
          (_) {
            emit(AddStaffSuccess());
          },
        );
      } else {
        // Create mode
        final result = await createEmployeeUseCase(body);
        result.fold(
          (failure) {
            emit(AddStaffFailure(error: failure.message));
          },
          (_) {
            emit(AddStaffSuccess());
          },
        );
      }
    } catch (e) {
      emit(AddStaffFailure(error: e.toString()));
    }
  }
}
