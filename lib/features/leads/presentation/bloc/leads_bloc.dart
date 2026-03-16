import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_leads_usecase.dart';
import 'leads_event.dart';
import 'leads_state.dart';

class LeadsBloc extends Bloc<LeadsEvent, LeadsState> {
  final GetLeadsUseCase getLeadsUseCase;

  LeadsBloc({required this.getLeadsUseCase}) : super(LeadsInitial()) {
    on<GetLeadsEvent>((event, emit) async {
      emit(LeadsLoading());
      try {
        final result = await getLeadsUseCase.call(
          page: event.page,
          limit: event.limit,
          status: event.status,
          leadStage: event.leadStage,
          search: event.search,
        );
        emit(LeadsLoaded(result));
      } catch (e) {
        emit(LeadsError(e.toString()));
      }
    });
  }
}
