import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/medical_equipment_entity.dart';
import '../../domain/usecases/get_medical_equipment_categories_usecase.dart';
import '../../domain/usecases/get_medical_equipment_list_usecase.dart';
import 'medical_equipment_event.dart';
import 'medical_equipment_state.dart';

class MedicalEquipmentBloc
    extends Bloc<MedicalEquipmentEvent, MedicalEquipmentState> {
  final GetMedicalEquipmentCategoriesUseCase getCategoriesUseCase;
  final GetMedicalEquipmentListUseCase getListUseCase;

  MedicalEquipmentBloc({
    required this.getCategoriesUseCase,
    required this.getListUseCase,
  }) : super(MedicalEquipmentInitial()) {
    on<LoadMedicalEquipmentCategoriesEvent>(_onLoadCategories);
    on<LoadMedicalEquipmentListEvent>(_onLoadList);
    on<SelectMedicalEquipmentCategoryEvent>(_onSelectCategory);
    on<SearchMedicalEquipmentEvent>(_onSearch);
  }

  Future<void> _onLoadCategories(LoadMedicalEquipmentCategoriesEvent event,
      Emitter<MedicalEquipmentState> emit) async {
    emit(MedicalEquipmentLoading());
    try {
      final categories = await getCategoriesUseCase();
      final response = await getListUseCase(page: 1);
      emit(MedicalEquipmentLoaded(categories: categories, response: response));
    } catch (e) {
      emit(MedicalEquipmentError(e.toString()));
    }
  }

  Future<void> _onLoadList(LoadMedicalEquipmentListEvent event,
      Emitter<MedicalEquipmentState> emit) async {
    final currentState = state;
    if (currentState is MedicalEquipmentLoaded) {
      try {
        if (event.isLoadMore) {
          emit(currentState.copyWith(isLoadingMore: true));
          final newResponse = await getListUseCase(
            page: event.page,
            categoryId: currentState.selectedCategoryId,
            search: currentState.searchQuery,
          );
          emit(currentState.copyWith(
            response: currentState.response.copyWith(
              list: [...currentState.response.list, ...newResponse.list],
              pagination: newResponse.pagination,
            ),
            isLoadingMore: false,
          ));
        } else {
          emit(MedicalEquipmentLoading());
          final response = await getListUseCase(
            page: 1,
            categoryId: event.categoryId ?? currentState.selectedCategoryId,
            search: event.search ?? currentState.searchQuery,
          );
          emit(currentState.copyWith(
            response: response,
            selectedCategoryId:
                event.categoryId ?? currentState.selectedCategoryId,
            searchQuery: event.search ?? currentState.searchQuery,
          ));
        }
      } catch (e) {
        emit(MedicalEquipmentError(e.toString()));
      }
    }
  }

  Future<void> _onSelectCategory(SelectMedicalEquipmentCategoryEvent event,
      Emitter<MedicalEquipmentState> emit) async {
    final currentState = state;
    if (currentState is MedicalEquipmentLoaded) {
      emit(MedicalEquipmentLoading());
      try {
        final response = await getListUseCase(
          page: 1,
          categoryId: event.categoryId,
          search: currentState.searchQuery,
        );
        emit(currentState.copyWith(
          response: response,
          selectedCategoryId: event.categoryId,
        ));
      } catch (e) {
        emit(MedicalEquipmentError(e.toString()));
      }
    }
  }

  Future<void> _onSearch(SearchMedicalEquipmentEvent event,
      Emitter<MedicalEquipmentState> emit) async {
    final currentState = state;
    if (currentState is MedicalEquipmentLoaded) {
      try {
        final response = await getListUseCase(
          page: 1,
          categoryId: currentState.selectedCategoryId,
          search: event.query,
        );
        emit(currentState.copyWith(
          response: response,
          searchQuery: event.query,
        ));
      } catch (e) {
        emit(MedicalEquipmentError(e.toString()));
      }
    }
  }
}

extension on MedicalEquipmentResponse {
  MedicalEquipmentResponse copyWith({
    List<MedicalEquipmentItem>? list,
    MedicalEquipmentPagination? pagination,
  }) {
    return MedicalEquipmentResponse(
      list: list ?? this.list,
      pagination: pagination ?? this.pagination,
    );
  }
}
