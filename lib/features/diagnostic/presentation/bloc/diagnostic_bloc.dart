import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_sources/diagnostic_service.dart';
import '../../data/models/diagnostic_model.dart';
import 'diagnostic_event.dart';
import 'diagnostic_state.dart';

class DiagnosticBloc extends Bloc<DiagnosticEvent, DiagnosticState> {
  final DiagnosticService _service;

  DiagnosticBloc(this._service) : super(DiagnosticInitial()) {
    on<LoadDiagnosticCategoriesEvent>(_onLoadCategories);
    on<LoadDiagnosticsEvent>(_onLoadDiagnostics);
    on<SelectDiagnosticCategoryEvent>(_onSelectCategory);
    on<SearchDiagnosticsEvent>(_onSearch);
  }

  Future<void> _onLoadCategories(LoadDiagnosticCategoriesEvent event, Emitter<DiagnosticState> emit) async {
    emit(DiagnosticLoading());
    try {
      final categories = await _service.getCategories();
      final response = await _service.getDiagnosticList();
      emit(DiagnosticLoaded(categories: categories, diagnosticResponse: response));
    } catch (e) {
      emit(DiagnosticError(e.toString()));
    }
  }

  Future<void> _onLoadDiagnostics(LoadDiagnosticsEvent event, Emitter<DiagnosticState> emit) async {
    final current = state;
    if (current is DiagnosticLoaded) {
      if (event.isLoadMore) emit(current.copyWith(isLoadingMore: true));
      try {
        final response = await _service.getDiagnosticList(
          page: event.page,
          categoryId: event.categoryId,
          search: event.search,
        );
        if (event.isLoadMore) {
          final updatedList = List<DiagnosticItem>.from(current.diagnosticResponse.list)..addAll(response.list);
          emit(current.copyWith(
            isLoadingMore: false,
            diagnosticResponse: DiagnosticResponse(list: updatedList, pagination: response.pagination),
          ));
        } else {
          emit(current.copyWith(
            diagnosticResponse: response,
            selectedCategoryId: event.categoryId,
            searchQuery: event.search,
            isLoadingMore: false,
          ));
        }
      } catch (e) {
        if (event.isLoadMore) {
          emit(current.copyWith(isLoadingMore: false));
        } else {
          emit(DiagnosticError(e.toString()));
        }
      }
    }
  }

  Future<void> _onSelectCategory(SelectDiagnosticCategoryEvent event, Emitter<DiagnosticState> emit) async {
    final current = state;
    if (current is DiagnosticLoaded) {
      add(LoadDiagnosticsEvent(categoryId: event.categoryId, search: current.searchQuery));
    }
  }

  Future<void> _onSearch(SearchDiagnosticsEvent event, Emitter<DiagnosticState> emit) async {
    final current = state;
    if (current is DiagnosticLoaded) {
      add(LoadDiagnosticsEvent(categoryId: current.selectedCategoryId, search: event.query));
    }
  }
}
