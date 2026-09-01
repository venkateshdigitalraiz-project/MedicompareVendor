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
    on<CreateHomeCareEvent>(_onCreate);
    on<UpdateHomeCareEvent>(_onUpdate);
    on<SearchHomeCareDropdownEvent>(_onSearchDropdown);
    on<FetchHomeCareDetailsEvent>(_onFetchDetails);
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

  Future<void> _onCreate(
      CreateHomeCareEvent event, Emitter<HomeCareState> emit) async {
    try {
      await _service.createHomeCare(event.payload);
      event.onSuccess();
      add(const LoadHomeCareListEvent(isRefresh: true));
    } catch (e) {
      event.onError(e.toString());
    }
  }

  Future<void> _onUpdate(
      UpdateHomeCareEvent event, Emitter<HomeCareState> emit) async {
    try {
      await _service.updateHomeCare(event.id, event.payload);
      event.onSuccess();
      add(const LoadHomeCareListEvent(isRefresh: true));
    } catch (e) {
      event.onError(e.toString());
    }
  }

  Future<void> _onSearchDropdown(
      SearchHomeCareDropdownEvent event, Emitter<HomeCareState> emit) async {
    emit(state.copyWith(isSearchingDropdown: true));
    try {
      final results = await _service.searchHomeCareDropdown(event.query);
      emit(state.copyWith(searchResults: results, isSearchingDropdown: false));
    } catch (_) {
      emit(state.copyWith(searchResults: [], isSearchingDropdown: false));
    }
  }

  Future<void> _onFetchDetails(
      FetchHomeCareDetailsEvent event, Emitter<HomeCareState> emit) async {
    try {
      final details = await _service.getTabletDetails(event.id);
      event.onSuccess(details);
    } catch (_) {}
  }
}
