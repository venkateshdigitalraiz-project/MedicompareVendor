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

  const LeadsLoaded(this.leadsList);

  @override
  List<Object?> get props => [leadsList];
}

class LeadsError extends LeadsState {
  final String message;

  const LeadsError(this.message);

  @override
  List<Object?> get props => [message];
}
