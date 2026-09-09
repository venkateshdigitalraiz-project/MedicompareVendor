import 'package:equatable/equatable.dart';
import '../../domain/entities/delivery_analytics_entity.dart';

abstract class DeliveryAnalyticsState extends Equatable {
  const DeliveryAnalyticsState();

  @override
  List<Object?> get props => [];
}

class DeliveryAnalyticsInitial extends DeliveryAnalyticsState {
  const DeliveryAnalyticsInitial();
}

class DeliveryAnalyticsLoading extends DeliveryAnalyticsState {
  final String selectedRange;

  const DeliveryAnalyticsLoading({this.selectedRange = '7days'});

  @override
  List<Object?> get props => [selectedRange];
}

class DeliveryAnalyticsLoaded extends DeliveryAnalyticsState {
  final DeliveryAnalyticsEntity analytics;
  final String selectedRange;

  const DeliveryAnalyticsLoaded({
    required this.analytics,
    this.selectedRange = '7days',
  });

  @override
  List<Object?> get props => [analytics, selectedRange];
}

class DeliveryAnalyticsError extends DeliveryAnalyticsState {
  final String message;
  final String selectedRange;

  const DeliveryAnalyticsError({
    required this.message,
    this.selectedRange = '7days',
  });

  @override
  List<Object?> get props => [message, selectedRange];
}
