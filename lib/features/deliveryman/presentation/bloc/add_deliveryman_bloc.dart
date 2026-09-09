import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_deliveryman_usecase.dart';
import 'add_deliveryman_event.dart';
import 'add_deliveryman_state.dart';

class AddDeliverymanBloc
    extends Bloc<AddDeliverymanEvent, AddDeliverymanState> {
  final CreateDeliverymanUseCase createDeliverymanUseCase;

  AddDeliverymanBloc({
    required this.createDeliverymanUseCase,
  }) : super(const AddDeliverymanInitial(currentStep: 1)) {
    on<ChangeAddDeliverymanStepEvent>(_onChangeStep);
    on<SubmitAddDeliverymanEvent>(_onSubmit);
  }

  void _onChangeStep(
    ChangeAddDeliverymanStepEvent event,
    Emitter<AddDeliverymanState> emit,
  ) {
    emit(AddDeliverymanInitial(currentStep: event.step));
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
}
