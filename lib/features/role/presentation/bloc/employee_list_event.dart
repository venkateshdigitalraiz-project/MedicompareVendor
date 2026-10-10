import 'package:equatable/equatable.dart';

abstract class EmployeeListEvent extends Equatable {
  const EmployeeListEvent();

  @override
  List<Object> get props => [];
}

class LoadEmployeeList extends EmployeeListEvent {}

class SearchEmployee extends EmployeeListEvent {
  final String query;

  const SearchEmployee(this.query);

  @override
  List<Object> get props => [query];
}
