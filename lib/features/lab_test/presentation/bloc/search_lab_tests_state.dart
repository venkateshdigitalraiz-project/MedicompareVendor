import 'package:equatable/equatable.dart';
import '../../data/models/lab_test_model.dart';

abstract class SearchLabTestsState extends Equatable {
  const SearchLabTestsState();

  @override
  List<Object?> get props => [];
}

class SearchLabTestsInitial extends SearchLabTestsState {}

class SearchLabTestsLoading extends SearchLabTestsState {}

class SearchLabTestsLoaded extends SearchLabTestsState {
  final List<LabTestDetails> results;

  const SearchLabTestsLoaded(this.results);

  @override
  List<Object?> get props => [results];
}

class SearchLabTestsError extends SearchLabTestsState {
  final String message;

  const SearchLabTestsError(this.message);

  @override
  List<Object?> get props => [message];
}
