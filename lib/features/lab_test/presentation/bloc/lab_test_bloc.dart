import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_sources/lab_test_service.dart';
import '../../data/models/lab_test_model.dart';
import 'lab_test_event.dart';
import 'lab_test_state.dart';

class LabTestBloc extends Bloc<LabTestEvent, LabTestState> {
  final LabTestService _labTestService;

  LabTestBloc(this._labTestService) : super(LabTestInitial()) {
    on<LoadLabTestCategoriesEvent>(_onLoadCategories);
    on<LoadLabTestsEvent>(_onLoadLabTests);
    on<SelectLabTestCategoryEvent>(_onSelectCategory);
    on<SearchLabTestsEvent>(_onSearchLabTests);
  }

  Future<void> _onLoadCategories(LoadLabTestCategoriesEvent event, Emitter<LabTestState> emit) async {
    emit(LabTestLoading());
    try {
      final categories = await _labTestService.getCategories();
      final response = await _labTestService.getLabTestList();
      emit(LabTestLoaded(categories: categories, labTestResponse: response));
    } catch (e) {
      emit(LabTestError(e.toString()));
    }
  }

  Future<void> _onLoadLabTests(LoadLabTestsEvent event, Emitter<LabTestState> emit) async {
    final currentState = state;
    if (currentState is LabTestLoaded) {
      if (event.isLoadMore) {
        emit(currentState.copyWith(isLoadingMore: true));
      }

      try {
        final response = await _labTestService.getLabTestList(
          page: event.page,
          categoryId: event.categoryId,
          search: event.search,
        );

        if (event.isLoadMore) {
          final newList = List<LabTestItem>.from(currentState.labTestResponse.list)..addAll(response.list);
          emit(currentState.copyWith(
            labTestResponse: LabTestResponse(list: newList, pagination: response.pagination),
            isLoadingMore: false,
            selectedCategoryId: event.categoryId,
            searchQuery: event.search,
          ));
        } else {
          emit(currentState.copyWith(
            labTestResponse: response,
            selectedCategoryId: event.categoryId,
            searchQuery: event.search,
          ));
        }
      } catch (e) {
        emit(LabTestError(e.toString()));
      }
    }
  }

  Future<void> _onSelectCategory(SelectLabTestCategoryEvent event, Emitter<LabTestState> emit) async {
    final currentState = state;
    if (currentState is LabTestLoaded) {
      add(LoadLabTestsEvent(categoryId: event.categoryId, search: currentState.searchQuery));
    }
  }

  Future<void> _onSearchLabTests(SearchLabTestsEvent event, Emitter<LabTestState> emit) async {
    final currentState = state;
    if (currentState is LabTestLoaded) {
      add(LoadLabTestsEvent(categoryId: currentState.selectedCategoryId, search: event.query));
    }
  }
}
