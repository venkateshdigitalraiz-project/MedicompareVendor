import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_deliveryman_usecase.dart';
import '../../domain/usecases/get_deliveryman_details_usecase.dart';
import '../../domain/usecases/update_deliveryman_usecase.dart';
import 'add_deliveryman_event.dart';
import 'add_deliveryman_state.dart';

class AddDeliverymanBloc
    extends Bloc<AddDeliverymanEvent, AddDeliverymanState> {
  final CreateDeliverymanUseCase createDeliverymanUseCase;
  final GetDeliverymanDetailsUseCase? getDeliverymanDetailsUseCase;
  final UpdateDeliverymanUseCase? updateDeliverymanUseCase;

  AddDeliverymanBloc({
    required this.createDeliverymanUseCase,
    this.getDeliverymanDetailsUseCase,
    this.updateDeliverymanUseCase,
  }) : super(const AddDeliverymanInitial(currentStep: 1)) {
    on<ChangeAddDeliverymanStepEvent>(_onChangeStep);
    on<LoadDeliverymanDetailsEvent>(_onLoadDetails);
    on<SubmitAddDeliverymanEvent>(_onSubmit);
    on<SubmitUpdateDeliverymanEvent>(_onUpdateSubmit);
  }

  void _onChangeStep(
    ChangeAddDeliverymanStepEvent event,
    Emitter<AddDeliverymanState> emit,
  ) {
    emit(AddDeliverymanInitial(currentStep: event.step));
  }

  Future<void> _onLoadDetails(
    LoadDeliverymanDetailsEvent event,
    Emitter<AddDeliverymanState> emit,
  ) async {
    emit(const AddDeliverymanDetailsLoading(currentStep: 1));
    try {
      if (getDeliverymanDetailsUseCase != null) {
        final deliveryman = await getDeliverymanDetailsUseCase!(event.id);
        emit(AddDeliverymanDetailsLoaded(
          deliveryman: deliveryman,
          currentStep: 1,
        ));
      } else {
        emit(const AddDeliverymanDetailsError(
          error: 'View usecase not provided',
          currentStep: 1,
        ));
      }
    } catch (e) {
      emit(AddDeliverymanDetailsError(
        error: e.toString().replaceAll('Exception: ', ''),
        currentStep: 1,
      ));
    }
  }

  Future<void> _onSubmit(
    SubmitAddDeliverymanEvent event,
    Emitter<AddDeliverymanState> emit,
  ) async {
    emit(const AddDeliverymanSubmitting(currentStep: 5));
    try {
      final success = await createDeliverymanUseCase(event.data);
      if (success) {
        emit(const AddDeliverymanSuccess(
          currentStep: 5,
          message: 'Deliveryman created successfully',
        ));
      } else {
        emit(const AddDeliverymanFailure(
          currentStep: 5,
          error: 'Failed to create deliveryman',
        ));
      }
    } catch (e) {
      emit(AddDeliverymanFailure(
        currentStep: 5,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateSubmit(
    SubmitUpdateDeliverymanEvent event,
    Emitter<AddDeliverymanState> emit,
  ) async {
    emit(const AddDeliverymanSubmitting(currentStep: 5));
    try {
      if (updateDeliverymanUseCase != null) {
        final success = await updateDeliverymanUseCase!(event.id, event.data);
        if (success) {
          emit(const AddDeliverymanSuccess(
            currentStep: 5,
            message: 'Deliveryman updated successfully',
          ));
        } else {
          emit(const AddDeliverymanFailure(
            currentStep: 5,
            error: 'Failed to update deliveryman',
          ));
        }
      } else {
        emit(const AddDeliverymanFailure(
          currentStep: 5,
          error: 'Update usecase not provided',
        ));
      }
    } catch (e) {
      emit(AddDeliverymanFailure(
        currentStep: 5,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
