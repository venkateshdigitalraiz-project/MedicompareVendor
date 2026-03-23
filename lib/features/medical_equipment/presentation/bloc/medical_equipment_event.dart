import 'package:equatable/equatable.dart';

abstract class MedicalEquipmentEvent extends Equatable {
  const MedicalEquipmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadMedicalEquipmentCategoriesEvent extends MedicalEquipmentEvent {
  const LoadMedicalEquipmentCategoriesEvent();
}

class LoadMedicalEquipmentListEvent extends MedicalEquipmentEvent {
  final int page;
  final String? categoryId;
  final String? search;
  final bool isLoadMore;

  const LoadMedicalEquipmentListEvent({
    this.page = 1,
    this.categoryId,
    this.search,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [page, categoryId, search, isLoadMore];
}

class SelectMedicalEquipmentCategoryEvent extends MedicalEquipmentEvent {
  final String categoryId;

  const SelectMedicalEquipmentCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchMedicalEquipmentEvent extends MedicalEquipmentEvent {
  final String query;

  const SearchMedicalEquipmentEvent(this.query);

  @override
  List<Object?> get props => [query];
}
