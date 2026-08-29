import 'package:equatable/equatable.dart';
import '../../data/models/lab_test_model.dart';

abstract class EditLeadState extends Equatable {
  const EditLeadState();

  @override
  List<Object?> get props => [];
}

class EditLeadInitial extends EditLeadState {}

class EditLeadLoading extends EditLeadState {}

class EditLeadLoaded extends EditLeadState {
  final LabTestItem product;

  const EditLeadLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class EditLeadUpdating extends EditLeadState {}

class EditLeadUpdated extends EditLeadState {}

class EditLeadError extends EditLeadState {
  final String message;

  const EditLeadError(this.message);

  @override
  List<Object?> get props => [message];
}
