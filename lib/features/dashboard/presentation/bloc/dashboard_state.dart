import '../../domain/entities/dashboard_entity.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardEntity dashboard;

  DashboardLoaded({required this.dashboard});
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError({required this.message});
}
