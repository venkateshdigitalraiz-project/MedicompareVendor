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
    emit(MedicineLoading());
    try {
      final categories = await _medicineService.getCategories();
      final medicineResponse = await _medicineService.getMedicineList();
      emit(MedicineLoaded(
        categories: categories,
        medicineResponse: medicineResponse,
      ));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  Future<void> _onLoadMedicines(
      LoadMedicinesEvent event, Emitter<MedicineState> emit) async {
    final currentState = state;
    if (currentState is MedicineLoaded) {
      if (event.isLoadMore) {
        emit(currentState.copyWith(isLoadingMore: true));
      }

      try {
        final medicineResponse = await _medicineService.getMedicineList(
          page: event.page,
          categoryId: event.categoryId,
          search: event.search,
        );

        if (event.isLoadMore) {
          final updatedList =
              List<MedicineItem>.from(currentState.medicineResponse.list)
                ..addAll(medicineResponse.list);

          emit(currentState.copyWith(
            isLoadingMore: false,
            medicineResponse: MedicineResponse(
              list: updatedList,
              pagination: medicineResponse.pagination,
            ),
          ));
        } else {
          emit(currentState.copyWith(
            medicineResponse: medicineResponse,
            selectedCategoryId: event.categoryId,
            searchQuery: event.search,
            isLoadingMore: false,
          ));
        }
      } catch (e) {
        if (event.isLoadMore) {
          emit(currentState.copyWith(isLoadingMore: false));
        } else {
          emit(MedicineError(e.toString()));
        }
      }
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
