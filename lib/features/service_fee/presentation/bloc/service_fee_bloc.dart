import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_service_fee.dart';
import 'service_fee_event.dart';
import 'service_fee_state.dart';

class ServiceFeeBloc extends Bloc<ServiceFeeEvent, ServiceFeeState> {
  final GetServiceFee getServiceFee;

  ServiceFeeBloc(this.getServiceFee) : super(ServiceFeeInitial()) {
    on<LoadServiceFee>(_onLoadServiceFee);
    on<RefreshServiceFee>(_onRefreshServiceFee);
  }

  Future<void> _onLoadServiceFee(
      LoadServiceFee event, Emitter<ServiceFeeState> emit) async {
    emit(ServiceFeeLoading());
    final result = await getServiceFee();
    result.fold(
      (failure) => emit(ServiceFeeFailure(failure.message)),
      (serviceFee) => emit(ServiceFeeSuccess(serviceFee)),
    );
  }

  Future<void> _onRefreshServiceFee(
      RefreshServiceFee event, Emitter<ServiceFeeState> emit) async {
    final currentState = state;
    if (currentState is ServiceFeeSuccess) {
      emit(ServiceFeeRefreshing(currentState.serviceFee));
    } else {
      emit(ServiceFeeLoading());
    }

    final result = await getServiceFee();
    result.fold(
      (failure) => emit(ServiceFeeFailure(failure.message)),
      (serviceFee) => emit(ServiceFeeSuccess(serviceFee)),
    );
  }
}
