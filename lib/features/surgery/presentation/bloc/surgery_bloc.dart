import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_sources/surgery_service.dart';
import '../../data/models/surgery_model.dart';
import 'surgery_event.dart';
import 'surgery_state.dart';

class SurgeryBloc extends Bloc<SurgeryEvent, SurgeryState> {
  final SurgeryService _surgeryService;

  SurgeryBloc(this._surgeryService) : super(SurgeryInitial()) {
    on<LoadSurgeryCategoriesEvent>(_onLoadCategories);
    on<LoadSurgeriesEvent>(_onLoadSurgeries);
    on<SelectSurgeryCategoryEvent>(_onSelectCategory);
    on<SearchSurgeriesEvent>(_onSearchSurgeries);
  }

  Future<void> _onLoadCategories(LoadSurgeryCategoriesEvent event, Emitter<SurgeryState> emit) async {
    emit(SurgeryLoading());
    try {
      final categories = await _surgeryService.getCategories();
      final surgeryResponse = await _surgeryService.getSurgeryList();
      emit(SurgeryLoaded(
        categories: categories,
        surgeryResponse: surgeryResponse,
      ));
    } catch (e) {
      emit(SurgeryError(e.toString()));
    }
  }

  Future<void> _onLoadSurgeries(LoadSurgeriesEvent event, Emitter<SurgeryState> emit) async {
    final currentState = state;
    if (currentState is SurgeryLoaded) {
      if (event.isLoadMore) {
        emit(currentState.copyWith(isLoadingMore: true));
      }

      try {
        final surgeryResponse = await _surgeryService.getSurgeryList(
          page: event.page,
          categoryId: event.categoryId,
          search: event.search,
        );

        if (event.isLoadMore) {
          final updatedList = List<SurgeryItem>.from(currentState.surgeryResponse.list)
            ..addAll(surgeryResponse.list);
          
          emit(currentState.copyWith(
            isLoadingMore: false,
            surgeryResponse: SurgeryResponse(
              list: updatedList,
              pagination: surgeryResponse.pagination,
            ),
          ));
        } else {
          emit(currentState.copyWith(
            surgeryResponse: surgeryResponse,
            selectedCategoryId: event.categoryId,
            searchQuery: event.search,
            isLoadingMore: false,
          ));
        }
      } catch (e) {
        if (event.isLoadMore) {
          emit(currentState.copyWith(isLoadingMore: false));
        } else {
          emit(SurgeryError(e.toString()));
        }
      }
    }
  }

  Future<void> _onSelectCategory(SelectSurgeryCategoryEvent event, Emitter<SurgeryState> emit) async {
    final currentState = state;
    if (currentState is SurgeryLoaded) {
      add(LoadSurgeriesEvent(
        categoryId: event.categoryId,
        search: currentState.searchQuery,
      ));
    }
  }

  Future<void> _onSearchSurgeries(SearchSurgeriesEvent event, Emitter<SurgeryState> emit) async {
    final currentState = state;
    if (currentState is SurgeryLoaded) {
      add(LoadSurgeriesEvent(
        categoryId: currentState.selectedCategoryId,
        search: event.query,
      ));
    }
  }
}
