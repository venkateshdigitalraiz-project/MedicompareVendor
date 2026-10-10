import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_employee_list_usecase.dart';
import 'employee_list_event.dart';
import 'employee_list_state.dart';
import '../../domain/entities/employee_entity.dart';

class EmployeeListBloc extends Bloc<EmployeeListEvent, EmployeeListState> {
  final GetEmployeeListUseCase getEmployeeListUseCase;
  List<EmployeeEntity> _allEmployees = [];

  EmployeeListBloc({required this.getEmployeeListUseCase}) : super(EmployeeListInitial()) {
    on<LoadEmployeeList>(_onLoadEmployeeList);
    on<SearchEmployee>(_onSearchEmployee);
  }

  void _onLoadEmployeeList(
      LoadEmployeeList event, Emitter<EmployeeListState> emit) async {
    emit(EmployeeListLoading());
    final result = await getEmployeeListUseCase();

    result.fold(
      (failure) => emit(EmployeeListError(message: failure.message)),
      (employees) {
        _allEmployees = employees;
        int activeCount = employees.where((e) => e.status.toLowerCase() == 'active').length;
        int onLeaveCount = employees.where((e) => e.status.toLowerCase() == 'on leave').length;
        int departmentsCount = employees.map((e) => e.department).toSet().length;

        emit(EmployeeListLoaded(
          employees: employees,
          totalStaff: employees.length,
          activeStaff: activeCount,
          onLeaveStaff: onLeaveCount,
          departments: departmentsCount,
        ));
      },
    );
  }

  void _onSearchEmployee(
      SearchEmployee event, Emitter<EmployeeListState> emit) {
    if (state is EmployeeListLoaded || state is EmployeeListLoading) {
      final query = event.query.toLowerCase();
      final filteredList = _allEmployees.where((employee) {
        return employee.name.toLowerCase().contains(query) ||
               employee.role.toLowerCase().contains(query) ||
               employee.department.toLowerCase().contains(query) ||
               employee.email.toLowerCase().contains(query);
      }).toList();
      
      int activeCount = _allEmployees.where((e) => e.status.toLowerCase() == 'active').length;
      int onLeaveCount = _allEmployees.where((e) => e.status.toLowerCase() == 'on leave').length;
      int departmentsCount = _allEmployees.map((e) => e.department).toSet().length;

      emit(EmployeeListLoaded(
        employees: filteredList,
        totalStaff: _allEmployees.length,
        activeStaff: activeCount,
        onLeaveStaff: onLeaveCount,
        departments: departmentsCount,
      ));
    }
  }
}
