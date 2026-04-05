import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardUseCase getDashboardUseCase;

  DashboardBloc({required this.getDashboardUseCase})
      : super(DashboardInitial()) {
    on<GetDashboardEvent>((event, emit) async {
      emit(DashboardLoading());
      try {
        final dashboard = await getDashboardUseCase();
        emit(DashboardLoaded(dashboard: dashboard));
      } catch (e) {
        emit(DashboardError(
            message: e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
