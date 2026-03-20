import 'package:equatable/equatable.dart';

abstract class HomeCareEvent extends Equatable {
  const HomeCareEvent();
  @override
  List<Object?> get props => [];
}

class LoadHomeCareCategoriesEvent extends HomeCareEvent {
  const LoadHomeCareCategoriesEvent();
}

class LoadHomeCareListEvent extends HomeCareEvent {
  final int page;
  final String categoryId;
  final String search;
  final bool isRefresh;

  const LoadHomeCareListEvent({
    this.page = 1,
    this.categoryId = '',
    this.search = '',
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, categoryId, search, isRefresh];
}

class SelectHomeCareCategoryEvent extends HomeCareEvent {
  final String categoryId;
  const SelectHomeCareCategoryEvent(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class SearchHomeCareEvent extends HomeCareEvent {
  final String query;
  const SearchHomeCareEvent(this.query);
  @override
  List<Object?> get props => [query];
}
