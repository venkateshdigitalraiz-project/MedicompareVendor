import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSubscriptionDataEvent extends SubscriptionEvent {}
