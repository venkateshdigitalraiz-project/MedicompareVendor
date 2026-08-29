import 'package:MediCompare/features/lab_test/domain/usecases/get_lab_test_details_usecase.dart';
import 'package:MediCompare/features/lab_test/domain/usecases/update_lab_test_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'edit_lead_event.dart';
import 'edit_lead_state.dart';

class EditLeadBloc extends Bloc<EditLeadEvent, EditLeadState> {
  final GetLabTestDetailsUseCase getLabTestDetailsUseCase;
  final UpdateLabTestUseCase updateLabTestUseCase;

  EditLeadBloc(this.getLabTestDetailsUseCase, this.updateLabTestUseCase)
      : super(EditLeadInitial()) {
    on<LoadLabTestDetailsEvent>(_onLoadLabTestDetails);
    on<UpdateLabTestDetailsEvent>(_onUpdateLabTestDetails);
  }

  Future<void> _onLoadLabTestDetails(
    LoadLabTestDetailsEvent event,
    Emitter<EditLeadState> emit,
  ) async {
    emit(EditLeadLoading());
    try {
      final product = await getLabTestDetailsUseCase(event.productId);
      emit(EditLeadLoaded(product));
    } catch (e) {
      emit(EditLeadError(e.toString()));
    }
  }

  Future<void> _onUpdateLabTestDetails(
    UpdateLabTestDetailsEvent event,
    Emitter<EditLeadState> emit,
  ) async {
    emit(EditLeadUpdating());
    try {
      await updateLabTestUseCase(event.productId, event.data);
      emit(EditLeadUpdated());
    } catch (e) {
      emit(EditLeadError(e.toString()));
    }
  }
}
