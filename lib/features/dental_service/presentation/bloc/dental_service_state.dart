import 'package:equatable/equatable.dart';
import '../../data/models/dental_service_model.dart';

abstract class DentalServiceState extends Equatable {
  const DentalServiceState();

  @override
  List<Object?> get props => [];
}

class DentalServiceInitial extends DentalServiceState {}

class DentalServiceLoading extends DentalServiceState {}

class DentalServiceLoaded extends DentalServiceState {
  final List<DentalServiceCategory> categories;
  final DentalServiceResponse response;
  final String selectedCategoryId;
  final String searchQuery;
  final bool isLoadingMore;

  const DentalServiceLoaded({
    required this.categories,
    required this.response,
    this.selectedCategoryId = '',
    this.searchQuery = '',
    this.isLoadingMore = false,
  });

  DentalServiceLoaded copyWith({
    List<DentalServiceCategory>? categories,
    DentalServiceResponse? response,
    String? selectedCategoryId,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return DentalServiceLoaded(
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

class DentalServiceError extends DentalServiceState {
  final String message;

  const DentalServiceError(this.message);

  @override
  List<Object?> get props => [message];
}
