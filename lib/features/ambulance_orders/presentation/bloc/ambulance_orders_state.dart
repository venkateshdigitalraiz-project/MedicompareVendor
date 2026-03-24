import 'package:equatable/equatable.dart';
import '../../domain/entities/ambulance_order_entity.dart';

abstract class AmbulanceOrdersState extends Equatable {
  const AmbulanceOrdersState();
  @override List<Object?> get props => [];
}

class AmbulanceOrdersInitial extends AmbulanceOrdersState {}

class AmbulanceOrdersLoading extends AmbulanceOrdersState {}

class AmbulanceOrdersLoaded extends AmbulanceOrdersState {
  final AmbulanceOrdersListEntity data;
  final bool isLoadingMore;
  final String selectedStatus;

  const AmbulanceOrdersLoaded(this.data, {
    this.isLoadingMore = false,
    this.selectedStatus = '',
  });

  AmbulanceOrdersLoaded copyWith({
    AmbulanceOrdersListEntity? data,
    bool? isLoadingMore,
    String? selectedStatus,
  }) => AmbulanceOrdersLoaded(
    data ?? this.data,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    selectedStatus: selectedStatus ?? this.selectedStatus,
  );

  @override List<Object?> get props => [data, isLoadingMore, selectedStatus];
}

class AmbulanceOrderDetailsLoaded extends AmbulanceOrdersState {
  final AmbulanceOrderEntity order;
  const AmbulanceOrderDetailsLoaded(this.order);
  @override List<Object?> get props => [order];
}

class AmbulanceOrdersError extends AmbulanceOrdersState {
  final String message;
  const AmbulanceOrdersError(this.message);
  @override List<Object?> get props => [message];
}
