import 'package:equatable/equatable.dart';
import '../../data/models/lab_test_package_model.dart';

abstract class LabTestPackageState extends Equatable {
  const LabTestPackageState();
  @override
  List<Object?> get props => [];
}

class LabTestPackageInitial extends LabTestPackageState {}

class LabTestPackageLoading extends LabTestPackageState {}

class LabTestPackageLoaded extends LabTestPackageState {
  final LabTestPackageResponse response;
  final bool isLoadingMore;
  final String searchQuery;
  final String selectedLabTestId;

  const LabTestPackageLoaded({
    required this.response,
    this.isLoadingMore = false,
    this.searchQuery = '',
    this.selectedLabTestId = '',
  });

  @override
  List<Object?> get props => [response, isLoadingMore, searchQuery, selectedLabTestId];

  LabTestPackageLoaded copyWith({
    LabTestPackageResponse? response,
    bool? isLoadingMore,
    String? searchQuery,
    String? selectedLabTestId,
  }) {
    return LabTestPackageLoaded(
      response: response ?? this.response,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedLabTestId: selectedLabTestId ?? this.selectedLabTestId,
    );
  }
}

class LabTestPackageError extends LabTestPackageState {
  final String message;
  const LabTestPackageError(this.message);
  @override
  List<Object?> get props => [message];
}
