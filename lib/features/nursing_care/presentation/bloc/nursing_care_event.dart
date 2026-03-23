import 'package:equatable/equatable.dart';

abstract class NursingCareEvent extends Equatable {
  const NursingCareEvent();
  @override
  List<Object?> get props => [];
}

class LoadNursingCareCategoriesEvent extends NursingCareEvent {
  const LoadNursingCareCategoriesEvent();
}

class LoadNursingCareListEvent extends NursingCareEvent {
  final int page;
  final String? categoryId;
  final String? search;
  final bool isLoadMore;

  const LoadNursingCareListEvent({
    this.page = 1,
    this.categoryId,
    this.search,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [page, categoryId, search, isLoadMore];
}

class SearchNursingCareEvent extends NursingCareEvent {
  final String query;
  const SearchNursingCareEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectNursingCareCategoryEvent extends NursingCareEvent {
  final String categoryId;
  const SelectNursingCareCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
