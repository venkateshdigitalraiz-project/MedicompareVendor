import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_sources/medicine_service.dart';
import '../../data/models/medicine_model.dart';
import 'medicine_event.dart';
import 'medicine_state.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final MedicineService _medicineService;

  MedicineBloc(this._medicineService) : super(MedicineInitial()) {
    on<LoadMedicineCategoriesEvent>(_onLoadCategories);
    on<LoadMedicinesEvent>(_onLoadMedicines);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<SearchMedicinesEvent>(_onSearchMedicines);
  }

  Future<void> _onLoadCategories(
      LoadMedicineCategoriesEvent event, Emitter<MedicineState> emit) async {
    final currentState = state;
    if (currentState is MedicineLoading) return; // Prevent concurrent calls

    List<MedicineCategory> existingCategories = [];
    if (currentState is MedicineLoaded) {
      existingCategories = currentState.categories;
    } else {
      emit(MedicineLoading());
    }

    try {
      // Only fetch categories if we don't have them yet
      final futures = <Future<dynamic>>[];
      if (existingCategories.isEmpty) {
        futures.add(_medicineService.getCategories());
      } else {
        futures.add(Future.value(existingCategories));
      }
      futures.add(_medicineService.getMedicineList(limit: 20));

      final results = await Future.wait(futures);

      emit(MedicineLoaded(
        categories: results[0] as List<MedicineCategory>,
        medicineResponse: results[1] as MedicineResponse,
        selectedCategoryId: currentState is MedicineLoaded ? currentState.selectedCategoryId : '',
        searchQuery: currentState is MedicineLoaded ? currentState.searchQuery : '',
      ));
    } catch (e) {
      if (state is! MedicineLoaded) {
        emit(MedicineError(e.toString()));
      }
    }
  }

  Future<void> _onLoadMedicines(
      LoadMedicinesEvent event, Emitter<MedicineState> emit) async {
    final currentState = state;
    if (currentState is MedicineLoaded) {
      // Prevent duplicate requests while one is already in progress
      if (currentState.isLoadingMore && event.isLoadMore) return;
      
      // If we're loading more, but we already have this page, skip
      if (event.isLoadMore && event.page <= currentState.medicineResponse.pagination.page) {
        return;
      }

      if (event.isLoadMore) {
        emit(currentState.copyWith(isLoadingMore: true));
      } else {
        // For fresh load, show global loader if not searching
        if (event.search.isEmpty && event.categoryId.isEmpty) {
             emit(MedicineLoading());
        } else {
           // For search/filter, just mark as loading more to avoid jumping UI
           emit(currentState.copyWith(isLoadingMore: true));
        }
      }

      try {
        final medicineResponse = await _medicineService.getMedicineList(
          page: event.page,
          categoryId: event.categoryId,
          search: event.search,
          limit: 15, // Slightly larger limit to reduce number of requests
        );

        // Re-check state to ensure we are still in loaded state
        final latestState = state;
        if (latestState is! MedicineLoaded && !event.isLoadMore) {
          // If fresh load and state changed (e.g. to Loading), we use fresh state
          // but usually we stay in Loaded or just came from Loading
        }
        
        // Use latest state data if we were already loaded
        final categories = (latestState is MedicineLoaded) ? latestState.categories : currentState.categories;

        if (event.isLoadMore && latestState is MedicineLoaded) {
          final updatedList =
              List<MedicineItem>.from(latestState.medicineResponse.list)
                ..addAll(medicineResponse.list);

          emit(latestState.copyWith(
            isLoadingMore: false,
            medicineResponse: MedicineResponse(
              list: updatedList,
              pagination: medicineResponse.pagination,
            ),
          ));
        } else {
          emit(MedicineLoaded(
            categories: categories,
            medicineResponse: medicineResponse,
            selectedCategoryId: event.categoryId,
            searchQuery: event.search,
            isLoadingMore: false,
          ));
        }
      } catch (e) {
        final latestState = state;
        if (latestState is MedicineLoaded) {
          emit(latestState.copyWith(isLoadingMore: false));
        } else {
          emit(MedicineError(e.toString()));
        }
      }
    } else if (state is MedicineLoading || state is MedicineInitial) {
       // Also handle case where we load medicines for the first time without categories
       // (Though current flow always loads categories first)
    }
  }

  Future<void> _onSelectCategory(
      SelectCategoryEvent event, Emitter<MedicineState> emit) async {
    final currentState = state;
    if (currentState is MedicineLoaded) {
      add(LoadMedicinesEvent(
        categoryId: event.categoryId,
        search: currentState.searchQuery,
      ));
    }
  }

  Future<void> _onSearchMedicines(
      SearchMedicinesEvent event, Emitter<MedicineState> emit) async {
    final currentState = state;
    if (currentState is MedicineLoaded) {
      add(LoadMedicinesEvent(
        categoryId: currentState.selectedCategoryId,
        search: event.query,
      ));
    }
  }
}
