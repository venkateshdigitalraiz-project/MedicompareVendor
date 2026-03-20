import 'package:equatable/equatable.dart';

abstract class LabTestEvent extends Equatable {
  const LabTestEvent();
  @override
  List<Object?> get props => [];
}

class LoadLabTestCategoriesEvent extends LabTestEvent {
  const LoadLabTestCategoriesEvent();
}

class LoadLabTestsEvent extends LabTestEvent {
  final int page;
  final String categoryId;
  final String search;
  final bool isLoadMore;

  const LoadLabTestsEvent({
    this.page = 1,
    this.categoryId = '',
    this.search = '',
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [page, categoryId, search, isLoadMore];
}

class SelectLabTestCategoryEvent extends LabTestEvent {
  final String categoryId;
  const SelectLabTestCategoryEvent(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class SearchLabTestsEvent extends LabTestEvent {
  final String query;
  const SearchLabTestsEvent(this.query);
  @override
  List<Object?> get props => [query];
}
