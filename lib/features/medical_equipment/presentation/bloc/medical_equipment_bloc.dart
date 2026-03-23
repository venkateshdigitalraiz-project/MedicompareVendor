import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_sources/medical_equipment_service.dart';
import 'medical_equipment_event.dart';
import 'medical_equipment_state.dart';
import '../../data/models/medical_equipment_model.dart';

class MedicalEquipmentBloc extends Bloc<MedicalEquipmentEvent, MedicalEquipmentState> {
  final MedicalEquipmentService service;

  MedicalEquipmentBloc(this.service) : super(MedicalEquipmentInitial()) {
    on<LoadMedicalEquipmentCategoriesEvent>(_onLoadCategories);
    on<LoadMedicalEquipmentListEvent>(_onLoadList);
    on<SelectMedicalEquipmentCategoryEvent>(_onSelectCategory);
    on<SearchMedicalEquipmentEvent>(_onSearch);
  }

  Future<void> _onLoadCategories(
      LoadMedicalEquipmentCategoriesEvent event, Emitter<MedicalEquipmentState> emit) async {
    emit(MedicalEquipmentLoading());
    try {
      final categories = await service.getCategories();
      final response = await service.getList(page: 1);
      emit(MedicalEquipmentLoaded(categories: categories, response: response));
    } catch (e) {
      emit(MedicalEquipmentError(e.toString()));
    }
  }

  Future<void> _onLoadList(
      LoadMedicalEquipmentListEvent event, Emitter<MedicalEquipmentState> emit) async {
    final currentState = state;
    if (currentState is MedicalEquipmentLoaded) {
      try {
        if (event.isLoadMore) {
          emit(currentState.copyWith(isLoadingMore: true));
          final newResponse = await service.getList(
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
          final response = await service.getList(
            page: 1,
            categoryId: event.categoryId ?? currentState.selectedCategoryId,
            search: event.search ?? currentState.searchQuery,
          );
          emit(currentState.copyWith(
            response: response,
            selectedCategoryId: event.categoryId ?? currentState.selectedCategoryId,
            searchQuery: event.search ?? currentState.searchQuery,
          ));
        }
      } catch (e) {
        emit(MedicalEquipmentError(e.toString()));
      }
    }
  }

  Future<void> _onSelectCategory(
      SelectMedicalEquipmentCategoryEvent event, Emitter<MedicalEquipmentState> emit) async {
    final currentState = state;
    if (currentState is MedicalEquipmentLoaded) {
      emit(MedicalEquipmentLoading());
      try {
        final response = await service.getList(
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

  Future<void> _onSearch(SearchMedicalEquipmentEvent event, Emitter<MedicalEquipmentState> emit) async {
    final currentState = state;
    if (currentState is MedicalEquipmentLoaded) {
      try {
        final response = await service.getList(
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

extension on dynamic {
  dynamic copyWith({List? list, dynamic pagination}) {
    return MedicalEquipmentResponse(
      list: (list ?? this.list).cast<MedicalEquipmentItem>(),
      pagination: pagination ?? this.pagination,
    );
  }
}
