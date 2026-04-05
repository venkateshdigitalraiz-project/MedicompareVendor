import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MediCompare/features/home_care/data/data_sources/home_care_service.dart';
import 'home_care_event.dart';
import 'home_care_state.dart';

class HomeCareBloc extends Bloc<HomeCareEvent, HomeCareState> {
  final HomeCareService _service;

  HomeCareBloc(this._service) : super(const HomeCareState()) {
    on<LoadHomeCareCategoriesEvent>(_onLoadCategories);
    on<LoadHomeCareListEvent>(_onLoadList);
    on<SelectHomeCareCategoryEvent>(_onSelectCategory);
    on<SearchHomeCareEvent>(_onSearch);
  }

  Future<void> _onLoadCategories(
      LoadHomeCareCategoriesEvent event, Emitter<HomeCareState> emit) async {
    try {
      final categories = await _service.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (_) {}
  }

  Future<void> _onLoadList(
      LoadHomeCareListEvent event, Emitter<HomeCareState> emit) async {
    if (event.isRefresh) {
      emit(state.copyWith(status: HomeCareStatus.loading, items: []));
    } else if (state.status == HomeCareStatus.initial) {
      emit(state.copyWith(status: HomeCareStatus.loading));
    }

    try {
      final response = await _service.getHomeCareList(
        page: event.page,
        categoryId: event.categoryId,
        search: event.search,
      );

      final newList =
          event.page == 1 ? response.list : [...state.items, ...response.list];
      emit(state.copyWith(
        status: HomeCareStatus.loaded,
        items: newList,
        pagination: response.pagination,
        selectedCategoryId: event.categoryId,
        searchQuery: event.search,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: HomeCareStatus.error, errorMessage: e.toString()));
    }
  }

  void _onSelectCategory(
      SelectHomeCareCategoryEvent event, Emitter<HomeCareState> emit) {
    add(LoadHomeCareListEvent(
        categoryId: event.categoryId,
        search: state.searchQuery ?? '',
        page: 1));
  }

  void _onSearch(SearchHomeCareEvent event, Emitter<HomeCareState> emit) {
    add(LoadHomeCareListEvent(
        categoryId: state.selectedCategoryId ?? '',
        search: event.query,
        page: 1));
  }
}
