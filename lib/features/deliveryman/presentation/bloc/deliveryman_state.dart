import 'package:equatable/equatable.dart';
import '../../domain/entities/deliveryman_entity.dart';

abstract class DeliverymanState extends Equatable {
  const DeliverymanState();

  @override
  List<Object?> get props => [];
}

class DeliverymanInitial extends DeliverymanState {
  const DeliverymanInitial();
}

class DeliverymanLoading extends DeliverymanState {
  const DeliverymanLoading();
}

class DeliverymanLoaded extends DeliverymanState {
  final List<DeliverymanEntity> items;
  final DeliverymanSummaryEntity summary;
  final DeliverymanPaginationEntity pagination;
  final String searchQuery;
  final String statusFilter;
  final bool isDeleting;
  final String? actionMessage;

  const DeliverymanLoaded({
    required this.items,
    required this.summary,
    required this.pagination,
    this.searchQuery = '',
    this.statusFilter = 'all',
    this.isDeleting = false,
    this.actionMessage,
  });

  DeliverymanLoaded copyWith({
    List<DeliverymanEntity>? items,
    DeliverymanSummaryEntity? summary,
    DeliverymanPaginationEntity? pagination,
    String? searchQuery,
    String? statusFilter,
    bool? isDeleting,
    String? actionMessage,
    bool clearActionMessage = false,
  }) {
    return DeliverymanLoaded(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      pagination: pagination ?? this.pagination,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      isDeleting: isDeleting ?? this.isDeleting,
      actionMessage:
          clearActionMessage ? null : (actionMessage ?? this.actionMessage),
    );
  }

  @override
  List<Object?> get props => [
        items,
        summary,
        pagination,
        searchQuery,
        statusFilter,
        isDeleting,
        actionMessage,
      ];
}

class DeliverymanError extends DeliverymanState {
  final String message;

  const DeliverymanError(this.message);

  @override
  List<Object?> get props => [message];
}
