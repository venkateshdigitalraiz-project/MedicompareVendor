import 'package:equatable/equatable.dart';
import '../../data/models/nursing_care_model.dart';

abstract class NursingCareState extends Equatable {
  const NursingCareState();
  @override
  List<Object?> get props => [];
}

class NursingCareInitial extends NursingCareState {}
class NursingCareLoading extends NursingCareState {}

class NursingCareLoaded extends NursingCareState {
  final List<NursingCareCategory> categories;
  final NursingCareResponse response;
  final String selectedCategoryId;
  final String searchQuery;
  final bool isLoadingMore;

  const NursingCareLoaded({
    required this.categories,
    required this.response,
    this.selectedCategoryId = '',
    this.searchQuery = '',
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [categories, response, selectedCategoryId, searchQuery, isLoadingMore];

  NursingCareLoaded copyWith({
    List<NursingCareCategory>? categories,
    NursingCareResponse? response,
    String? selectedCategoryId,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return NursingCareLoaded(
      categories: categories ?? this.categories,
      response: response ?? this.response,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class NursingCareError extends NursingCareState {
  final String message;
  const NursingCareError(this.message);

  @override
  List<Object?> get props => [message];
}
