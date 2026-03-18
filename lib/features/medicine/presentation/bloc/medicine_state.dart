import 'package:equatable/equatable.dart';
import '../../data/models/medicine_model.dart';

abstract class MedicineState extends Equatable {
  const MedicineState();

  @override
  List<Object?> get props => [];
}

class MedicineInitial extends MedicineState {}

class MedicineLoading extends MedicineState {}

class MedicineLoaded extends MedicineState {
  final List<MedicineCategory> categories;
  final MedicineResponse medicineResponse;
  final String selectedCategoryId;
  final String searchQuery;
  final bool isLoadingMore;

  const MedicineLoaded({
    required this.categories,
    required this.medicineResponse,
    this.selectedCategoryId = '',
    this.searchQuery = '',
    this.isLoadingMore = false,
  });

  MedicineLoaded copyWith({
    List<MedicineCategory>? categories,
    MedicineResponse? medicineResponse,
    String? selectedCategoryId,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return MedicineLoaded(
      categories: categories ?? this.categories,
      medicineResponse: medicineResponse ?? this.medicineResponse,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [categories, medicineResponse, selectedCategoryId, searchQuery, isLoadingMore];
}

class MedicineError extends MedicineState {
  final String message;

  const MedicineError(this.message);

  @override
  List<Object?> get props => [message];
}
