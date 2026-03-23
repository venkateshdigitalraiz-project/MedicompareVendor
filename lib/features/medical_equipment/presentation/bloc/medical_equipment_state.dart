import 'package:equatable/equatable.dart';
import '../../data/models/medical_equipment_model.dart';

abstract class MedicalEquipmentState extends Equatable {
  const MedicalEquipmentState();

  @override
  List<Object?> get props => [];
}

class MedicalEquipmentInitial extends MedicalEquipmentState {}

class MedicalEquipmentLoading extends MedicalEquipmentState {}

class MedicalEquipmentLoaded extends MedicalEquipmentState {
  final List<MedicalEquipmentCategory> categories;
  final MedicalEquipmentResponse response;
  final String selectedCategoryId;
  final String searchQuery;
  final bool isLoadingMore;

  const MedicalEquipmentLoaded({
    required this.categories,
    required this.response,
    this.selectedCategoryId = '',
    this.searchQuery = '',
    this.isLoadingMore = false,
  });

  MedicalEquipmentLoaded copyWith({
    List<MedicalEquipmentCategory>? categories,
    MedicalEquipmentResponse? response,
    String? selectedCategoryId,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return MedicalEquipmentLoaded(
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

class MedicalEquipmentError extends MedicalEquipmentState {
  final String message;

  const MedicalEquipmentError(this.message);

  @override
  List<Object?> get props => [message];
}
