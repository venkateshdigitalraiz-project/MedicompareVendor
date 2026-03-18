import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSubscriptionDataEvent extends SubscriptionEvent {}

class CreateOrderEvent extends SubscriptionEvent {
  final int amount;
  final String currency;
  final String receipt;
  final dynamic plan; // Keep the whole plan object for convenience

  CreateOrderEvent({
    required this.amount,
    required this.currency,
    required this.receipt,
    required this.plan,
  });

  @override
  List<Object?> get props => [amount, currency, receipt, plan];
}

class PurchasePlanEvent extends SubscriptionEvent {
  final String planId;
  final String razorpayPaymentId;
  final int amount;

  PurchasePlanEvent({
    required this.planId,
    required this.razorpayPaymentId,
    required this.amount,
  });

  @override
  List<Object?> get props => [planId, razorpayPaymentId, amount];
}
