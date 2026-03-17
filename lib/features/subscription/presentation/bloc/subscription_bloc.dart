import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository repository;

  SubscriptionBloc({required this.repository}) : super(SubscriptionInitial()) {
    on<LoadSubscriptionDataEvent>((event, emit) async {
      emit(SubscriptionLoading());
      try {
        final results = await Future.wait([
          repository.getSubscriptionHistory(),
          repository.getSubscriptionPlans(),
        ]);
        
        emit(SubscriptionLoaded(
          history: results[0] as dynamic,
          plans: results[1] as dynamic,
        ));
      } catch (e) {
        emit(SubscriptionError(message: e.toString()));
      }
    });
  }
}
