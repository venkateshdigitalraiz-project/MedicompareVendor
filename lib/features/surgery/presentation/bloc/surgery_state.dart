import 'package:equatable/equatable.dart';
import '../../data/models/surgery_model.dart';

abstract class SurgeryState extends Equatable {
  const SurgeryState();

  @override
  List<Object?> get props => [];
}

class SurgeryInitial extends SurgeryState {}

class SurgeryLoading extends SurgeryState {}

class SurgeryLoaded extends SurgeryState {
  final List<SurgeryCategory> categories;
  final SurgeryResponse surgeryResponse;
  final String selectedCategoryId;
  final String searchQuery;
  final bool isLoadingMore;

  const SurgeryLoaded({
    required this.categories,
    required this.surgeryResponse,
    this.selectedCategoryId = '',
    this.searchQuery = '',
    this.isLoadingMore = false,
  });

  SurgeryLoaded copyWith({
    List<SurgeryCategory>? categories,
    SurgeryResponse? surgeryResponse,
    String? selectedCategoryId,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return SurgeryLoaded(
      categories: categories ?? this.categories,
      surgeryResponse: surgeryResponse ?? this.surgeryResponse,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [categories, surgeryResponse, selectedCategoryId, searchQuery, isLoadingMore];
}

class SurgeryError extends SurgeryState {
  final String message;

  const SurgeryError(this.message);

  @override
  List<Object?> get props => [message];
}
