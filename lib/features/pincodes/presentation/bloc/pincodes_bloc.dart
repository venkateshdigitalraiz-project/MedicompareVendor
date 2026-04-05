import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pincode_entity.dart';
import '../../domain/usecases/get_pincodes_usecase.dart';
import '../../domain/usecases/create_pincode_usecase.dart';
import '../../domain/usecases/update_pincode_usecase.dart';
import '../../domain/usecases/delete_pincode_usecase.dart';
import 'pincodes_event.dart';
import 'pincodes_state.dart';

class PincodesBloc extends Bloc<PincodesEvent, PincodesState> {
  final GetPincodesUseCase getPincodesUseCase;
  final CreatePincodeUseCase createPincodeUseCase;
  final UpdatePincodeUseCase updatePincodeUseCase;
  final DeletePincodeUseCase deletePincodeUseCase;

  PincodesBloc({
    required this.getPincodesUseCase,
    required this.createPincodeUseCase,
    required this.updatePincodeUseCase,
    required this.deletePincodeUseCase,
  }) : super(PincodesInitial()) {
    on<GetPincodesEvent>((event, emit) async {
      emit(PincodesLoading());
      try {
        final pincodes = await getPincodesUseCase();
        emit(PincodesLoaded(pincodes: pincodes));
      } catch (e) {
        emit(
            PincodesError(message: e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<CreatePincodeEvent>((event, emit) async {
      final currentState = state;
      List<PincodeDataEntity> currentPincodes = [];
      if (currentState is PincodesLoaded) {
        currentPincodes = currentState.pincodes;
      }

      try {
        await createPincodeUseCase(
          pincode: event.pincode,
          estimatedDelivery: event.estimatedDelivery,
          status: event.status,
        );
        emit(PincodeCreated());
        add(GetPincodesEvent());
      } catch (e) {
        emit(PincodeOperationError(
            message: e.toString().replaceAll('Exception: ', '')));
        if (currentPincodes.isNotEmpty) {
          emit(PincodesLoaded(pincodes: currentPincodes));
        }
      }
    });

    on<UpdatePincodeEvent>((event, emit) async {
      final currentState = state;
      List<PincodeDataEntity> currentPincodes = [];
      if (currentState is PincodesLoaded) {
        currentPincodes = currentState.pincodes;
      }

      try {
        await updatePincodeUseCase(
          id: event.id,
          pincode: event.pincode,
          estimatedDelivery: event.estimatedDelivery,
          status: event.status,
        );
        emit(PincodeUpdated());
        add(GetPincodesEvent());
      } catch (e) {
        emit(PincodeOperationError(
            message: e.toString().replaceAll('Exception: ', '')));
        if (currentPincodes.isNotEmpty) {
          emit(PincodesLoaded(pincodes: currentPincodes));
        }
      }
    });

    on<DeletePincodeEvent>((event, emit) async {
      final currentState = state;
      List<PincodeDataEntity> currentPincodes = [];
      if (currentState is PincodesLoaded) {
        currentPincodes = currentState.pincodes;
      }

      try {
        await deletePincodeUseCase(event.id);
        emit(PincodeDeleted());
        add(GetPincodesEvent());
      } catch (e) {
        emit(PincodeOperationError(
            message: e.toString().replaceAll('Exception: ', '')));
        if (currentPincodes.isNotEmpty) {
          emit(PincodesLoaded(pincodes: currentPincodes));
        }
      }
    });
  }
}
