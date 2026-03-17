import 'package:equatable/equatable.dart';
import '../../data/models/subscription_model.dart';

abstract class SubscriptionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionHistory history;
  final SubscriptionListResponse plans;

  SubscriptionLoaded({required this.history, required this.plans});

  @override
  List<Object?> get props => [history, plans];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  SubscriptionError({required this.message});

  @override
  List<Object?> get props => [message];
}
