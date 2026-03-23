import 'package:equatable/equatable.dart';

abstract class MedicalTreatmentEvent extends Equatable {
  const MedicalTreatmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadMedicalTreatmentCategoriesEvent extends MedicalTreatmentEvent {
  const LoadMedicalTreatmentCategoriesEvent();
}

class LoadMedicalTreatmentListEvent extends MedicalTreatmentEvent {
  final int page;
  final String? categoryId;
  final String? search;
  final bool isLoadMore;

  const LoadMedicalTreatmentListEvent({
    this.page = 1,
    this.categoryId,
    this.search,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [page, categoryId, search, isLoadMore];
}

class SelectMedicalTreatmentCategoryEvent extends MedicalTreatmentEvent {
  final String categoryId;

  const SelectMedicalTreatmentCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchMedicalTreatmentEvent extends MedicalTreatmentEvent {
  final String query;

  const SearchMedicalTreatmentEvent(this.query);

  @override
  List<Object?> get props => [query];
}
