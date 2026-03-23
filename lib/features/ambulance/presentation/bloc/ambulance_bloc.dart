import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ambulance_entity.dart';
import '../../domain/usecases/get_ambulance_list_usecase.dart';
import '../../domain/usecases/get_ambulance_categories_usecase.dart';
import '../../domain/usecases/get_ambulance_facilities_usecase.dart';
import '../../domain/usecases/get_ambulance_names_usecase.dart';
import '../../domain/usecases/create_ambulance_usecase.dart';
import '../../domain/usecases/update_ambulance_usecase.dart';
import '../../domain/usecases/delete_ambulance_usecase.dart';
import 'ambulance_event.dart';
import 'ambulance_state.dart';

class AmbulanceBloc extends Bloc<AmbulanceEvent, AmbulanceState> {
  final GetAmbulanceListUseCase getAmbulanceListUseCase;
  final GetAmbulanceCategoriesUseCase getAmbulanceCategoriesUseCase;
  final GetAmbulanceFacilitiesUseCase getAmbulanceFacilitiesUseCase;
  final GetAmbulanceNamesUseCase getAmbulanceNamesUseCase;
  final CreateAmbulanceUseCase createAmbulanceUseCase;
  final UpdateAmbulanceUseCase updateAmbulanceUseCase;
  final DeleteAmbulanceUseCase deleteAmbulanceUseCase;

  AmbulanceBloc({
    required this.getAmbulanceListUseCase,
    required this.getAmbulanceCategoriesUseCase,
    required this.getAmbulanceFacilitiesUseCase,
    required this.getAmbulanceNamesUseCase,
    required this.createAmbulanceUseCase,
    required this.updateAmbulanceUseCase,
    required this.deleteAmbulanceUseCase,
  }) : super(AmbulanceInitial()) {
    on<GetAmbulanceListEvent>(_onGetAmbulanceList);
    on<GetAmbulanceFormOptionsEvent>(_onGetFormOptions);
    on<SearchAmbulanceNamesEvent>(_onSearchAmbulanceNames);
    on<CreateAmbulanceEvent>(_onCreateAmbulance);
    on<UpdateAmbulanceEvent>(_onUpdateAmbulance);
    on<DeleteAmbulanceEvent>(_onDeleteAmbulance);
  }

  Future<void> _onGetAmbulanceList(
    GetAmbulanceListEvent event,
    Emitter<AmbulanceState> emit,
  ) async {
    final currentState = state;
    if (event.isLoadMore && currentState is AmbulanceLoaded) {
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      emit(AmbulanceLoading());
    }

    try {
      final result = await getAmbulanceListUseCase.call(
        page: event.page,
        limit: event.limit,
        categoryId: event.categoryId,
        search: event.search,
      );

      if (event.isLoadMore && currentState is AmbulanceLoaded) {
        final updatedItems = currentState.ambulanceList.items + result.items;
        emit(AmbulanceLoaded(
          AmbulanceListEntity(
            items: updatedItems,
            pagination: result.pagination,
          ),
          isLoadingMore: false,
        ));
      } else {
        emit(AmbulanceLoaded(result));
      }
    } catch (e) {
      emit(AmbulanceError(e.toString()));
    }
  }

  Future<void> _onGetFormOptions(
    GetAmbulanceFormOptionsEvent event,
    Emitter<AmbulanceState> emit,
  ) async {
    // Do NOT emit AmbulanceLoading here — it would wipe the list state
    try {
      final facilities = await getAmbulanceFacilitiesUseCase.call();
      final categories = await getAmbulanceCategoriesUseCase.call();
      emit(AmbulanceFormOptionsLoaded(
        facilities: facilities,
        categories: categories,
      ));
    } catch (_) {
      // Silently fail — the sheet handles this via its local cached state
    }
  }

  Future<void> _onSearchAmbulanceNames(
    SearchAmbulanceNamesEvent event,
    Emitter<AmbulanceState> emit,
  ) async {
    emit(AmbulanceNamesSearching());
    try {
      final names = await getAmbulanceNamesUseCase.call(event.query);
      emit(AmbulanceNamesSearched(names));
    } catch (e) {
      emit(AmbulanceError(e.toString()));
    }
  }

  Future<void> _onCreateAmbulance(
    CreateAmbulanceEvent event,
    Emitter<AmbulanceState> emit,
  ) async {
    emit(AmbulanceLoading());
    try {
      await createAmbulanceUseCase.call(event.payload);
      emit(const AmbulanceOperationSuccess('Ambulance service created successfully'));
    } catch (e) {
      emit(AmbulanceError(e.toString()));
    }
  }

  Future<void> _onUpdateAmbulance(
    UpdateAmbulanceEvent event,
    Emitter<AmbulanceState> emit,
  ) async {
    emit(AmbulanceLoading());
    try {
      await updateAmbulanceUseCase.call(event.id, event.payload);
      emit(const AmbulanceOperationSuccess('Ambulance service updated successfully'));
    } catch (e) {
      emit(AmbulanceError(e.toString()));
    }
  }

  Future<void> _onDeleteAmbulance(
    DeleteAmbulanceEvent event,
    Emitter<AmbulanceState> emit,
  ) async {
    emit(AmbulanceLoading());
    try {
      await deleteAmbulanceUseCase.call(event.id);
      emit(const AmbulanceOperationSuccess('Ambulance service deleted successfully'));
    } catch (e) {
      emit(AmbulanceError(e.toString()));
    }
  }
}
