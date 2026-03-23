import 'package:equatable/equatable.dart';
import '../../domain/entities/lead_entity.dart';

abstract class LeadsState extends Equatable {
  const LeadsState();

  @override
  List<Object?> get props => [];
}

class LeadsInitial extends LeadsState {}

class LeadsLoading extends LeadsState {}

class LeadsLoaded extends LeadsState {
  final LeadsListEntity leadsList;
  final bool isLoadingMore;

  const LeadsLoaded(this.leadsList, {this.isLoadingMore = false});

  LeadsLoaded copyWith({
    LeadsListEntity? leadsList,
    bool? isLoadingMore,
  }) {
    return LeadsLoaded(
      leadsList ?? this.leadsList,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [leadsList, isLoadingMore];
}

class LeadsError extends LeadsState {
  final String message;

  const LeadsError(this.message);

  @override
  List<Object?> get props => [message];
}

class LeadDetailsLoaded extends LeadsState {
  final LeadDetailsEntity leadDetails;

  const LeadDetailsLoaded(this.leadDetails);

  @override
  List<Object?> get props => [leadDetails];
}
