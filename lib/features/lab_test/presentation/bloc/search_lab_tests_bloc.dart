import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/search_lab_tests_usecase.dart';
import 'search_lab_tests_event.dart';
import 'search_lab_tests_state.dart';

class SearchLabTestsBloc extends Bloc<SearchLabTestsEvent, SearchLabTestsState> {
  final SearchLabTestsUseCase _searchUseCase;

  SearchLabTestsBloc(this._searchUseCase) : super(SearchLabTestsInitial()) {
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onSearchQueryChanged(
      SearchQueryChangedEvent event, Emitter<SearchLabTestsState> emit) async {
    if (event.query.isEmpty) {
      emit(SearchLabTestsInitial());
      return;
    }

    emit(SearchLabTestsLoading());
    try {
      final results = await _searchUseCase(event.query);
      emit(SearchLabTestsLoaded(results));
    } catch (e) {
      emit(SearchLabTestsError(e.toString()));
    }
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<SearchLabTestsState> emit) {
    emit(SearchLabTestsInitial());
  }
}
