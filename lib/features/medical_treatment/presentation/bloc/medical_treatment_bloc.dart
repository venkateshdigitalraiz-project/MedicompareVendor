import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_sources/medical_treatment_service.dart';
import 'medical_treatment_event.dart';
import 'medical_treatment_state.dart';
import '../../data/models/medical_treatment_model.dart';

class MedicalTreatmentBloc extends Bloc<MedicalTreatmentEvent, MedicalTreatmentState> {
  final MedicalTreatmentService service;

  MedicalTreatmentBloc(this.service) : super(MedicalTreatmentInitial()) {
    on<LoadMedicalTreatmentCategoriesEvent>(_onLoadCategories);
    on<LoadMedicalTreatmentListEvent>(_onLoadList);
    on<SelectMedicalTreatmentCategoryEvent>(_onSelectCategory);
    on<SearchMedicalTreatmentEvent>(_onSearch);
  }

  Future<void> _onLoadCategories(
      LoadMedicalTreatmentCategoriesEvent event, Emitter<MedicalTreatmentState> emit) async {
    emit(MedicalTreatmentLoading());
    try {
      final categories = await service.getCategories();
      final response = await service.getList(page: 1);
      emit(MedicalTreatmentLoaded(categories: categories, response: response));
    } catch (e) {
      emit(MedicalTreatmentError(e.toString()));
    }
  }

  Future<void> _onLoadList(
      LoadMedicalTreatmentListEvent event, Emitter<MedicalTreatmentState> emit) async {
    final currentState = state;
    if (currentState is MedicalTreatmentLoaded) {
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
          emit(MedicalTreatmentLoading());
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
        emit(MedicalTreatmentError(e.toString()));
      }
    }
  }

  Future<void> _onSelectCategory(
      SelectMedicalTreatmentCategoryEvent event, Emitter<MedicalTreatmentState> emit) async {
    final currentState = state;
    if (currentState is MedicalTreatmentLoaded) {
      emit(MedicalTreatmentLoading());
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
        emit(MedicalTreatmentError(e.toString()));
      }
    }
  }

  Future<void> _onSearch(SearchMedicalTreatmentEvent event, Emitter<MedicalTreatmentState> emit) async {
    final currentState = state;
    if (currentState is MedicalTreatmentLoaded) {
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
        emit(MedicalTreatmentError(e.toString()));
      }
    }
  }
}

extension on dynamic {
  dynamic copyWith({List? list, dynamic pagination}) {
    return MedicalTreatmentResponse(
      list: (list ?? this.list).cast<MedicalTreatmentItem>(),
      pagination: pagination ?? this.pagination,
    );
  }
}
