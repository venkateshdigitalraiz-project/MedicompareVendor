import 'package:equatable/equatable.dart';
import '../../domain/entities/delivery_order_entity.dart';

abstract class DeliveryOrdersState extends Equatable {
  const DeliveryOrdersState();

  @override
  List<Object?> get props => [];
}

class DeliveryOrdersInitial extends DeliveryOrdersState {
  const DeliveryOrdersInitial();
}

class DeliveryOrdersLoading extends DeliveryOrdersState {
  const DeliveryOrdersLoading();
}

class DeliveryOrdersLoaded extends DeliveryOrdersState {
  final List<DeliveryOrderEntity> items;
  final DeliveryOrdersSummaryEntity summary;
  final DeliveryOrdersPaginationEntity pagination;
  final String searchQuery;
  final String statusFilter;

  const DeliveryOrdersLoaded({
    required this.items,
    required this.summary,
    required this.pagination,
    this.searchQuery = '',
    this.statusFilter = 'all',
  });

  DeliveryOrdersLoaded copyWith({
    List<DeliveryOrderEntity>? items,
    DeliveryOrdersSummaryEntity? summary,
    DeliveryOrdersPaginationEntity? pagination,
    String? searchQuery,
    String? statusFilter,
  }) {
    return DeliveryOrdersLoaded(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      pagination: pagination ?? this.pagination,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [
        items,
        summary,
        pagination,
        searchQuery,
        statusFilter,
      ];
}

class DeliveryOrdersError extends DeliveryOrdersState {
  final String message;

  const DeliveryOrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
