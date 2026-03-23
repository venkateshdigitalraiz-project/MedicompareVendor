import 'package:equatable/equatable.dart';
import '../../domain/entities/ambulance_entity.dart';

abstract class AmbulanceState extends Equatable {
  const AmbulanceState();

  @override
  List<Object?> get props => [];
}

class AmbulanceInitial extends AmbulanceState {}

class AmbulanceLoading extends AmbulanceState {}

class AmbulanceLoaded extends AmbulanceState {
  final AmbulanceListEntity ambulanceList;
  final bool isLoadingMore;
  final String selectedCategoryId;
  final String searchQuery;

  const AmbulanceLoaded(
    this.ambulanceList, {
    this.isLoadingMore = false,
    this.selectedCategoryId = '',
    this.searchQuery = '',
  });

  AmbulanceLoaded copyWith({
    AmbulanceListEntity? ambulanceList,
    bool? isLoadingMore,
    String? selectedCategoryId,
    String? searchQuery,
  }) {
    return AmbulanceLoaded(
      ambulanceList ?? this.ambulanceList,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [ambulanceList, isLoadingMore, selectedCategoryId, searchQuery];
}

class AmbulanceFormOptionsLoaded extends AmbulanceState {
  final List<AmbulanceFacilityEntity> facilities;
  final List<AmbulanceCategoryEntity> categories;

  const AmbulanceFormOptionsLoaded({
    required this.facilities,
    required this.categories,
  });

  @override
  List<Object?> get props => [facilities, categories];
}

class AmbulanceNamesSearching extends AmbulanceState {}

class AmbulanceNamesSearched extends AmbulanceState {
  final List<AmbulanceNameOptionEntity> names;
  const AmbulanceNamesSearched(this.names);

  @override
  List<Object?> get props => [names];
}

class AmbulanceOperationSuccess extends AmbulanceState {
  final String message;
  const AmbulanceOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AmbulanceError extends AmbulanceState {
  final String message;
  const AmbulanceError(this.message);

  @override
  List<Object?> get props => [message];
}
