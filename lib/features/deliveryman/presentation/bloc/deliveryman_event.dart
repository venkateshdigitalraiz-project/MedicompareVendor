import 'package:equatable/equatable.dart';

abstract class DeliverymanEvent extends Equatable {
  const DeliverymanEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeliverymenEvent extends DeliverymanEvent {
  final int page;
  final int limit;
  final String search;
  final String status;
  final bool isRefresh;

  const LoadDeliverymenEvent({
    this.page = 1,
    this.limit = 10,
    this.search = '',
    this.status = 'all',
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, search, status, isRefresh];
}

class SearchDeliverymenEvent extends DeliverymanEvent {
  final String query;

  const SearchDeliverymenEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterDeliverymenEvent extends DeliverymanEvent {
  final String status;

  const FilterDeliverymenEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class ChangeDeliverymenPageEvent extends DeliverymanEvent {
  final int page;

  const ChangeDeliverymenPageEvent(this.page);

  @override
  List<Object?> get props => [page];
}

class DeleteDeliverymanEvent extends DeliverymanEvent {
  final String id;

  const DeleteDeliverymanEvent(this.id);

  @override
  List<Object?> get props => [id];
}
