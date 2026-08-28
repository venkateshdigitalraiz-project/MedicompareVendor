import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_branch_usecase.dart';
import '../../domain/repositories/branch_repository.dart';
import 'branch_event.dart';
import 'branch_state.dart';

class BranchBloc extends Bloc<BranchEvent, BranchState> {
  final CreateBranchUseCase createBranchUseCase;
  final BranchRepository? branchRepository;

  BranchBloc({
    required this.createBranchUseCase,
    this.branchRepository,
  }) : super(BranchInitial()) {
    on<CreateBranchEvent>(_onCreateBranchEvent);
    on<FetchBranchListEvent>(_onFetchBranchListEvent);
  }

  Future<void> _onCreateBranchEvent(
    CreateBranchEvent event,
    Emitter<BranchState> emit,
  ) async {
    emit(BranchLoading());
    try {
      await createBranchUseCase.call(event.data, image: event.image);
      emit(const BranchCreateSuccess());
    } catch (e) {
      emit(BranchCreateFailure(
        message: e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', ''),
      ));
    }
  }

  Future<void> _onFetchBranchListEvent(
    FetchBranchListEvent event,
    Emitter<BranchState> emit,
  ) async {
    if (branchRepository == null) return;
    emit(BranchLoading());
    try {
      final response = await branchRepository!.getBranchList(search: event.search);
      emit(BranchListLoaded(branches: response.data.list));
    } catch (e) {
      emit(BranchListFailure(
        message: e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', ''),
      ));
    }
  }
}
