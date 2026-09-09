import 'package:equatable/equatable.dart';

abstract class DeliveryAnalyticsEvent extends Equatable {
  const DeliveryAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeliveryAnalyticsEvent extends DeliveryAnalyticsEvent {
  final String range;
  final bool isRefresh;

  const LoadDeliveryAnalyticsEvent({
    this.range = '7days',
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [range, isRefresh];
}

class ChangeDeliveryAnalyticsRangeEvent extends DeliveryAnalyticsEvent {
  final String range;

  const ChangeDeliveryAnalyticsRangeEvent(this.range);

  @override
  List<Object?> get props => [range];
}
