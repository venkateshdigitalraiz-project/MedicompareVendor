import 'package:equatable/equatable.dart';

abstract class AmbulanceOrdersEvent extends Equatable {
  const AmbulanceOrdersEvent();
  @override List<Object?> get props => [];
}

class LoadAmbulanceOrdersEvent extends AmbulanceOrdersEvent {
  final int page;
  final int limit;
  final String status;
  final String search;
  final bool isLoadMore;
  const LoadAmbulanceOrdersEvent({
    this.page = 1,
    this.limit = 10,
    this.status = '',
    this.search = '',
    this.isLoadMore = false,
  });
  @override List<Object?> get props => [page, limit, status, search, isLoadMore];
}

class LoadAmbulanceOrderDetailsEvent extends AmbulanceOrdersEvent {
  final String id;
  const LoadAmbulanceOrderDetailsEvent(this.id);
  @override List<Object?> get props => [id];
}
