import 'package:equatable/equatable.dart';
import '../../data/models/lab_test_model.dart';

abstract class LabTestState extends Equatable {
  const LabTestState();
  @override
  List<Object?> get props => [];
}

class LabTestInitial extends LabTestState {}

class LabTestLoading extends LabTestState {}

class LabTestLoaded extends LabTestState {
  final List<LabTestCategory> categories;
  final LabTestResponse labTestResponse;
  final String selectedCategoryId;
  final String searchQuery;
  final bool isLoadingMore;

  const LabTestLoaded({
    required this.categories,
    required this.labTestResponse,
    this.selectedCategoryId = '',
    this.searchQuery = '',
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [categories, labTestResponse, selectedCategoryId, searchQuery, isLoadingMore];

  LabTestLoaded copyWith({
    List<LabTestCategory>? categories,
    LabTestResponse? labTestResponse,
    String? selectedCategoryId,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return LabTestLoaded(
      categories: categories ?? this.categories,
      labTestResponse: labTestResponse ?? this.labTestResponse,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class LabTestError extends LabTestState {
  final String message;
  const LabTestError(this.message);
  @override
  List<Object?> get props => [message];
}
