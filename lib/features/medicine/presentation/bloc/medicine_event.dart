import 'package:equatable/equatable.dart';

abstract class MedicineEvent extends Equatable {
  const MedicineEvent();

  @override
  List<Object?> get props => [];
}

class LoadMedicineCategoriesEvent extends MedicineEvent {}

class LoadMedicinesEvent extends MedicineEvent {
  final int page;
  final String categoryId;
  final String search;
  final bool isLoadMore;

  const LoadMedicinesEvent({
    this.page = 1,
    this.categoryId = '',
    this.search = '',
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [page, categoryId, search, isLoadMore];
}

class SelectCategoryEvent extends MedicineEvent {
  final String categoryId;

  const SelectCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchMedicinesEvent extends MedicineEvent {
  final String query;

  const SearchMedicinesEvent(this.query);

  @override
  List<Object?> get props => [query];
}
