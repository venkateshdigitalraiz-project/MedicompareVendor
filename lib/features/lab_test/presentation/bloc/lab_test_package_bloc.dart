import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_sources/lab_test_service.dart';
import '../../data/models/lab_test_model.dart';
import '../../data/models/lab_test_package_model.dart';
import 'lab_test_package_event.dart';
import 'lab_test_package_state.dart';

class LabTestPackageBloc
    extends Bloc<LabTestPackageEvent, LabTestPackageState> {
  final LabTestService _labTestService;

  LabTestPackageBloc(this._labTestService) : super(LabTestPackageInitial()) {
    on<LoadLabTestPackagesEvent>(_onLoadPackages);
    on<SearchLabTestPackagesEvent>(_onSearchPackages);
    on<SelectLabTestForPackageFilterEvent>(_onSelectLabTest);
  }

  Future<void> _onLoadPackages(
      LoadLabTestPackagesEvent event, Emitter<LabTestPackageState> emit) async {
    final currentState = state;

    if (currentState is LabTestPackageInitial) {
      emit(LabTestPackageLoading());
    } else if (currentState is LabTestPackageLoaded) {
      if (event.isLoadMore) {
        emit(currentState.copyWith(isLoadingMore: true));
      }
    } else {
      if (!event.isLoadMore) emit(LabTestPackageLoading());
    }

    try {
      final response = await _labTestService.getPackageList(
        page: event.page,
        search: event.search,
        labTestId: event.labTestId,
      );

      if (state is LabTestPackageLoaded && event.isLoadMore) {
        final currentLoaded = state as LabTestPackageLoaded;
        final newList = [...currentLoaded.response.list, ...response.list];
        emit(currentLoaded.copyWith(
          response: response.copyWith(
              list: newList), // Assuming copyWith exists or just manually
          isLoadingMore: false,
          searchQuery: event.search,
          selectedLabTestId: event.labTestId,
        ));
      } else {
        emit(LabTestPackageLoaded(
          response: response,
          searchQuery: event.search,
          selectedLabTestId: event.labTestId,
        ));
      }
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('No packages found') && !event.isLoadMore) {
        emit(LabTestPackageLoaded(
          response: const LabTestPackageResponse(
              list: [],
              pagination: LabTestPagination(
                  page: 1, limit: 10, total: 0, totalPages: 0)),
          searchQuery: event.search,
          selectedLabTestId: event.labTestId,
        ));
      } else if (event.isLoadMore) {
        if (state is LabTestPackageLoaded) {
          emit((state as LabTestPackageLoaded).copyWith(isLoadingMore: false));
        }
      } else {
        emit(LabTestPackageError(errorMessage));
      }
    }
  }

  Future<void> _onSearchPackages(SearchLabTestPackagesEvent event,
      Emitter<LabTestPackageState> emit) async {
    final currentState = state;
    if (currentState is LabTestPackageLoaded) {
      add(LoadLabTestPackagesEvent(
        search: event.query,
        labTestId: currentState.selectedLabTestId,
      ));
    } else if (currentState is LabTestPackageInitial ||
        currentState is LabTestPackageError) {
      add(LoadLabTestPackagesEvent(search: event.query));
    }
  }

  Future<void> _onSelectLabTest(SelectLabTestForPackageFilterEvent event,
      Emitter<LabTestPackageState> emit) async {
    final currentState = state;
    if (currentState is LabTestPackageLoaded) {
      add(LoadLabTestPackagesEvent(
        search: currentState.searchQuery,
        labTestId: event.labTestId,
      ));
    } else {
      add(LoadLabTestPackagesEvent(labTestId: event.labTestId));
    }
  }
}
