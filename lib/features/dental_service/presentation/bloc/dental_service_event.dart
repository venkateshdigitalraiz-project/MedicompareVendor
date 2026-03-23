import 'package:equatable/equatable.dart';

abstract class DentalServiceEvent extends Equatable {
  const DentalServiceEvent();

  @override
  List<Object?> get props => [];
}

class LoadDentalServiceCategoriesEvent extends DentalServiceEvent {
  const LoadDentalServiceCategoriesEvent();
}

class LoadDentalServiceListEvent extends DentalServiceEvent {
  final String? categoryId;
  final String? search;
  final int page;
  final bool isLoadMore;

  const LoadDentalServiceListEvent({
    this.categoryId,
    this.search,
    this.page = 1,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [categoryId, search, page, isLoadMore];
}

class SelectDentalServiceCategoryEvent extends DentalServiceEvent {
  final String categoryId;

  const SelectDentalServiceCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchDentalServiceEvent extends DentalServiceEvent {
  final String query;

  const SearchDentalServiceEvent(this.query);

  @override
  List<Object?> get props => [query];
}
