import 'package:equatable/equatable.dart';
import '../../data/models/branch_model.dart';

abstract class BranchState extends Equatable {
  const BranchState();

  @override
  List<Object?> get props => [];
}

class BranchInitial extends BranchState {}

class BranchLoading extends BranchState {}

class BranchCreateSuccess extends BranchState {
  final String message;

  const BranchCreateSuccess({this.message = 'Branch created successfully!'});

  @override
  List<Object?> get props => [message];
}

class BranchCreateFailure extends BranchState {
  final String message;

  const BranchCreateFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class BranchListLoaded extends BranchState {
  final List<Branch> branches;

  const BranchListLoaded({required this.branches});

  @override
  List<Object?> get props => [branches];
}

class BranchListFailure extends BranchState {
  final String message;

  const BranchListFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
