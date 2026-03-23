import 'package:equatable/equatable.dart';
import '../../data/models/medical_treatment_model.dart';

abstract class MedicalTreatmentState extends Equatable {
  const MedicalTreatmentState();

  @override
  List<Object?> get props => [];
}

class MedicalTreatmentInitial extends MedicalTreatmentState {}

class MedicalTreatmentLoading extends MedicalTreatmentState {}

class MedicalTreatmentLoaded extends MedicalTreatmentState {
  final List<MedicalTreatmentCategory> categories;
  final MedicalTreatmentResponse response;
  final String selectedCategoryId;
  final String searchQuery;
  final bool isLoadingMore;

  const MedicalTreatmentLoaded({
    required this.categories,
    required this.response,
    this.selectedCategoryId = '',
    this.searchQuery = '',
    this.isLoadingMore = false,
  });

  MedicalTreatmentLoaded copyWith({
    List<MedicalTreatmentCategory>? categories,
    MedicalTreatmentResponse? response,
    String? selectedCategoryId,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return MedicalTreatmentLoaded(
      categories: categories ?? this.categories,
      response: response ?? this.response,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [categories, response, selectedCategoryId, searchQuery, isLoadingMore];
}

class MedicalTreatmentError extends MedicalTreatmentState {
  final String message;

  const MedicalTreatmentError(this.message);

  @override
  List<Object?> get props => [message];
}
