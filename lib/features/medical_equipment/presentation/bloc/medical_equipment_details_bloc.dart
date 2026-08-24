import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_medical_equipment_details_usecase.dart';
import 'medical_equipment_details_event.dart';
import 'medical_equipment_details_state.dart';

class MedicalEquipmentDetailsBloc
    extends Bloc<MedicalEquipmentDetailsEvent, MedicalEquipmentDetailsState> {
  final GetMedicalEquipmentDetailsUseCase getDetailsUseCase;

  MedicalEquipmentDetailsBloc({
    required this.getDetailsUseCase,
  }) : super(MedicalEquipmentDetailsInitial()) {
    on<LoadMedicalEquipmentDetailsEvent>(_onLoadDetails);
  }

  Future<void> _onLoadDetails(
    LoadMedicalEquipmentDetailsEvent event,
    Emitter<MedicalEquipmentDetailsState> emit,
  ) async {
    emit(MedicalEquipmentDetailsLoading());
    try {
      final item = await getDetailsUseCase(event.id);
      emit(MedicalEquipmentDetailsLoaded(item));
    } catch (e) {
      emit(MedicalEquipmentDetailsError(e.toString()));
    }
  }
}
