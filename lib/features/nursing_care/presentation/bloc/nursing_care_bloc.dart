import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_sources/nursing_care_service.dart';
import '../../data/models/nursing_care_model.dart';
import 'nursing_care_event.dart';
import 'nursing_care_state.dart';

class NursingCareBloc extends Bloc<NursingCareEvent, NursingCareState> {
  final NursingCareService service;

  NursingCareBloc(this.service) : super(NursingCareInitial()) {
    on<LoadNursingCareCategoriesEvent>(_onLoadCategories);
    on<LoadNursingCareListEvent>(_onLoadList);
    on<SelectNursingCareCategoryEvent>(_onSelectCategory);
    on<SearchNursingCareEvent>(_onSearch);
  }

  Future<void> _onLoadCategories(LoadNursingCareCategoriesEvent event, Emitter<NursingCareState> emit) async {
    emit(NursingCareLoading());
    try {
      final cats = await service.getCategories();
      final listResp = await service.getNursingCareList();
      emit(NursingCareLoaded(categories: cats, response: listResp));
    } catch (e) {
      emit(NursingCareError(e.toString()));
    }
  }

  Future<void> _onLoadList(LoadNursingCareListEvent event, Emitter<NursingCareState> emit) async {
    final s = state;
    if (s is NursingCareLoaded) {
      if (event.isLoadMore) {
        emit(s.copyWith(isLoadingMore: true));
      } else {
        emit(NursingCareLoading());
      }
      try {
        final resp = await service.getNursingCareList(
          page: event.page,
          categoryId: event.categoryId ?? s.selectedCategoryId,
          search: event.search ?? s.searchQuery,
        );
        if (event.isLoadMore) {
          emit(s.copyWith(
            response: NursingCareResponse(
              list: [...s.response.list, ...resp.list],
              pagination: resp.pagination,
            ),
            isLoadingMore: false,
          ));
        } else {
          emit(s.copyWith(
            response: resp,
            selectedCategoryId: event.categoryId,
            searchQuery: event.search,
          ));
        }
      } catch (e) {
        emit(NursingCareError(e.toString()));
      }
    }
  }

  void _onSelectCategory(SelectNursingCareCategoryEvent event, Emitter<NursingCareState> emit) {
    final s = state;
    if (s is NursingCareLoaded) {
      add(LoadNursingCareListEvent(categoryId: event.categoryId, search: s.searchQuery));
    }
  }

  void _onSearch(SearchNursingCareEvent event, Emitter<NursingCareState> emit) {
    final s = state;
    if (s is NursingCareLoaded) {
      add(LoadNursingCareListEvent(search: event.query, categoryId: s.selectedCategoryId));
    }
  }
}
