import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_leads_usecase.dart';
import '../../domain/usecases/get_lead_details_usecase.dart';
import '../../domain/entities/lead_entity.dart';
import 'leads_event.dart';
import 'leads_state.dart';

class LeadsBloc extends Bloc<LeadsEvent, LeadsState> {
  final GetLeadsUseCase getLeadsUseCase;
  final GetLeadDetailsUseCase getLeadDetailsUseCase;

  LeadsBloc({
    required this.getLeadsUseCase,
    required this.getLeadDetailsUseCase,
  }) : super(LeadsInitial()) {
    on<GetLeadsEvent>((event, emit) async {
      final currentState = state;
      if (event.isLoadMore && currentState is LeadsLoaded) {
        emit(currentState.copyWith(isLoadingMore: true));
      } else {
        emit(LeadsLoading());
      }
      
      try {
        final result = await getLeadsUseCase.call(
          page: event.page,
          limit: event.limit,
          status: event.status,
          leadStage: event.leadStage,
          search: event.search,
        );
        
        if (event.isLoadMore && currentState is LeadsLoaded) {
          final updatedLeads = currentState.leadsList.leads + result.leads;
          emit(LeadsLoaded(
            LeadsListEntity(
              leads: updatedLeads,
              pagination: result.pagination,
            ),
            isLoadingMore: false,
          ));
        } else {
          emit(LeadsLoaded(result));
        }
      } catch (e) {
        emit(LeadsError(e.toString()));
      }
    });

    on<GetLeadDetailsEvent>((event, emit) async {
      emit(LeadsLoading());
      try {
        final result = await getLeadDetailsUseCase.call(event.leadId);
        emit(LeadDetailsLoaded(result));
      } catch (e) {
        emit(LeadsError(e.toString()));
      }
    });
  }
}
