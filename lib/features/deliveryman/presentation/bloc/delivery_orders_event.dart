import 'package:equatable/equatable.dart';

abstract class DeliveryOrdersEvent extends Equatable {
  const DeliveryOrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeliveryOrdersEvent extends DeliveryOrdersEvent {
  final int page;
  final int limit;
  final String search;
  final String status;
  final bool isRefresh;

  const LoadDeliveryOrdersEvent({
    this.page = 1,
    this.limit = 10,
    this.search = '',
    this.status = 'all',
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, search, status, isRefresh];
}

class SearchDeliveryOrdersEvent extends DeliveryOrdersEvent {
  final String query;

  const SearchDeliveryOrdersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterDeliveryOrdersEvent extends DeliveryOrdersEvent {
  final String status;

  const FilterDeliveryOrdersEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class ChangeDeliveryOrdersPageEvent extends DeliveryOrdersEvent {
  final int page;

  const ChangeDeliveryOrdersPageEvent(this.page);

  @override
  List<Object?> get props => [page];
}
