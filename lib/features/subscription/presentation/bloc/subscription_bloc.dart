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

    on<CreateOrderEvent>((event, emit) async {
      emit(OrderProcessing());
      try {
        final orderId = await repository.createOrder(
          amount: event.amount,
          currency: event.currency,
          receipt: event.receipt,
        );
        emit(OrderCreated(
            orderId: orderId, amount: event.amount, plan: event.plan));
      } catch (e) {
        emit(OrderFailure(message: e.toString()));
      }
    });

    on<PurchasePlanEvent>((event, emit) async {
      emit(PurchaseProcessing());
      try {
        final success = await repository.purchasePlan(
          planId: event.planId,
          razorpayPaymentId: event.razorpayPaymentId,
          amount: event.amount,
        );
        if (success) {
          emit(PurchaseSuccess(message: "Plan upgraded successfully!"));
          add(LoadSubscriptionDataEvent()); // Refresh data
        } else {
          emit(SubscriptionError(
              message: "Failed to verify purchase. Please contact support."));
        }
      } catch (e) {
        emit(SubscriptionError(message: e.toString()));
      }
    });
  }
}
