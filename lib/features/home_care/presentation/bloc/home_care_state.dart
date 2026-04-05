import 'package:equatable/equatable.dart';
import 'package:MediCompare/features/home_care/data/models/home_care_model.dart';

enum HomeCareStatus { initial, loading, loaded, error }

class HomeCareState extends Equatable {
  final HomeCareStatus status;
  final List<HomeCareCategory> categories;
  final List<HomeCareItem> items;
  final HomeCarePagination? pagination;
  final String? selectedCategoryId;
  final String? searchQuery;
  final String? errorMessage;

  const HomeCareState({
    this.status = HomeCareStatus.initial,
    this.categories = const [],
    this.items = const [],
    this.pagination,
    this.selectedCategoryId,
    this.searchQuery,
    this.errorMessage,
  });

  HomeCareState copyWith({
    HomeCareStatus? status,
    List<HomeCareCategory>? categories,
    List<HomeCareItem>? items,
    HomeCarePagination? pagination,
    String? selectedCategoryId,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HomeCareState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        items,
        pagination,
        selectedCategoryId,
        searchQuery,
        errorMessage
      ];
}
