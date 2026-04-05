import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_sources/dental_service_service.dart';
import '../../data/models/dental_service_model.dart';
import 'dental_service_event.dart';
import 'dental_service_state.dart';

class DentalServiceBloc extends Bloc<DentalServiceEvent, DentalServiceState> {
  final DentalServiceService service;

  DentalServiceBloc(this.service) : super(DentalServiceInitial()) {
    on<LoadDentalServiceCategoriesEvent>(_onLoadCategories);
    on<LoadDentalServiceListEvent>(_onLoadList);
    on<SelectDentalServiceCategoryEvent>(_onSelectCategory);
    on<SearchDentalServiceEvent>(_onSearch);
  }

  Future<void> _onLoadCategories(LoadDentalServiceCategoriesEvent event,
      Emitter<DentalServiceState> emit) async {
    emit(DentalServiceLoading());
    try {
      final cats = await service.getCategories();
      final listResp = await service.getDentalServiceList();
      emit(DentalServiceLoaded(categories: cats, response: listResp));
    } catch (e) {
      emit(DentalServiceError(e.toString()));
    }
  }

  Future<void> _onLoadList(LoadDentalServiceListEvent event,
      Emitter<DentalServiceState> emit) async {
    final s = state;
    if (s is DentalServiceLoaded) {
      if (event.isLoadMore) {
        emit(s.copyWith(isLoadingMore: true));
      }

      try {
        final resp = await service.getDentalServiceList(
          page: event.page,
          categoryId: event.categoryId ?? s.selectedCategoryId,
          search: event.search ?? s.searchQuery,
        );
        if (event.isLoadMore) {
          emit(s.copyWith(
            response: DentalServiceResponse(
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
            isLoadingMore: false,
          ));
        }
      } catch (e) {
        if (event.isLoadMore) {
          emit(s.copyWith(isLoadingMore: false));
        } else {
          emit(DentalServiceError(e.toString()));
        }
      }
    }
  }

  void _onSelectCategory(SelectDentalServiceCategoryEvent event,
      Emitter<DentalServiceState> emit) {
    final s = state;
    if (s is DentalServiceLoaded) {
      add(LoadDentalServiceListEvent(
          categoryId: event.categoryId, search: s.searchQuery));
    }
  }

  void _onSearch(
      SearchDentalServiceEvent event, Emitter<DentalServiceState> emit) {
    final s = state;
    if (s is DentalServiceLoaded) {
      add(LoadDentalServiceListEvent(
          search: event.query, categoryId: s.selectedCategoryId));
    }
  }
}
