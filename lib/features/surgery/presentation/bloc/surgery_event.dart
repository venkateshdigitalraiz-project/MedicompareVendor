import 'package:equatable/equatable.dart';

abstract class SurgeryEvent extends Equatable {
  const SurgeryEvent();

  @override
  List<Object?> get props => [];
}

class LoadSurgeryCategoriesEvent extends SurgeryEvent {}

class LoadSurgeriesEvent extends SurgeryEvent {
  final int page;
  final String categoryId;
  final String search;
  final bool isLoadMore;

  const LoadSurgeriesEvent({
    this.page = 1,
    this.categoryId = '',
    this.search = '',
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [page, categoryId, search, isLoadMore];
}

class SelectSurgeryCategoryEvent extends SurgeryEvent {
  final String categoryId;

  const SelectSurgeryCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchSurgeriesEvent extends SurgeryEvent {
  final String query;

  const SearchSurgeriesEvent(this.query);

  @override
  List<Object?> get props => [query];
}
