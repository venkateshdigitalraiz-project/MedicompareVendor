import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_service_fee.dart';
import 'service_fee_event.dart';
import 'service_fee_state.dart';

import '../../domain/usecases/update_service_fee_settings_usecase.dart';
import '../../domain/entities/service_fee.dart';

class ServiceFeeBloc extends Bloc<ServiceFeeEvent, ServiceFeeState> {
  final GetServiceFee getServiceFee;
  final UpdateServiceFeeSettingsUseCase updateServiceFeeSettingsUseCase;

  ServiceFeeBloc({
    required this.getServiceFee,
    required this.updateServiceFeeSettingsUseCase,
  }) : super(ServiceFeeInitial()) {
    on<LoadServiceFee>(_onLoadServiceFee);
    on<RefreshServiceFee>(_onRefreshServiceFee);
    on<SaveServiceFee>(_onSaveServiceFee);
    on<ResetServiceFee>(_onResetServiceFee);
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

  Future<void> _onSaveServiceFee(
      SaveServiceFee event, Emitter<ServiceFeeState> emit) async {
    final ServiceFee fee = event.currentFee as ServiceFee;
    
    // Save current state to revert if needed
    final currentState = state;
    
    emit(ServiceFeeActionLoading());
    
    final payload = {
      "branchOverrides": {},
      "services": {
        if (fee.labTests != null)
          "labtests": {
            "visit": {
              "visitType": fee.labTests!.visitType,
              "homeVisitFee": fee.labTests!.homeVisitFee,
              "urgentSurcharge": fee.labTests!.urgentSurcharge,
              "maxRadius": fee.labTests!.maxRadius,
            }
          },
        if (fee.medicalEquipment != null)
          "medicalequipment": {
            "delivery": {
              "minDeliveryFee": fee.medicalEquipment!.minDeliveryFee,
              "baseRadius": fee.medicalEquipment!.baseRadius,
              "perKmCharge": fee.medicalEquipment!.perKmCharge,
              "minOrderForFreeDelivery": fee.medicalEquipment!.minOrderForFreeDelivery,
            }
          },
        if (fee.medicine != null)
          "medicine": {
            "delivery": {
              "minDeliveryFee": fee.medicine!.minDeliveryFee,
              "baseRadius": fee.medicine!.baseRadius,
              "perKmCharge": fee.medicine!.perKmCharge,
              "minOrderForFreeDelivery": fee.medicine!.minOrderForFreeDelivery,
            }
          }
      }
    };

    final result = await updateServiceFeeSettingsUseCase(payload);
    result.fold(
      (failure) {
        emit(ServiceFeeFailure(failure.message));
        if (currentState is ServiceFeeSuccess) {
          emit(ServiceFeeSuccess(currentState.serviceFee));
        }
      },
      (success) {
        emit(const ServiceFeeUpdateSuccess("Settings updated successfully"));
      },
    );
  }

  Future<void> _onResetServiceFee(
      ResetServiceFee event, Emitter<ServiceFeeState> emit) async {
    final currentState = state;
    emit(ServiceFeeActionLoading());
    
    final payload = {
      "branchOverrides": {},
      "services": {
        "labtests": {
          "visit": {
            "visitType": "both",
            "homeVisitFee": 150,
            "urgentSurcharge": 100,
            "maxRadius": 20
          }
        },
        "medicalequipment": {
          "delivery": {
            "minDeliveryFee": 150,
            "baseRadius": 8,
            "perKmCharge": 15,
            "minOrderForFreeDelivery": 1500
          }
        },
        "medicine": {
          "delivery": {
            "minDeliveryFee": 40,
            "baseRadius": 5,
            "perKmCharge": 8,
            "minOrderForFreeDelivery": 500
          }
        }
      }
    };

    final result = await updateServiceFeeSettingsUseCase(payload);
    result.fold(
      (failure) {
        emit(ServiceFeeFailure(failure.message));
        if (currentState is ServiceFeeSuccess) {
          emit(ServiceFeeSuccess(currentState.serviceFee));
        }
      },
      (success) {
        emit(const ServiceFeeUpdateSuccess("Settings reset successfully"));
      },
    );
  }
}
