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

class CreateMedicalTreatmentEvent extends MedicalTreatmentEvent {
  final Map<String, dynamic> payload;
  final Function onSuccess;
  final Function(String) onError;

  const CreateMedicalTreatmentEvent(
    this.payload, {
    required this.onSuccess,
    required this.onError,
  });

  @override
  List<Object?> get props => [payload];
}

class UpdateMedicalTreatmentEvent extends MedicalTreatmentEvent {
  final String id;
  final Map<String, dynamic> payload;
  final Function onSuccess;
  final Function(String) onError;

  const UpdateMedicalTreatmentEvent(
    this.id,
    this.payload, {
    required this.onSuccess,
    required this.onError,
  });

  @override
  List<Object?> get props => [id, payload];
}

class FetchTreatmentTabletDetailsEvent extends MedicalTreatmentEvent {
  final String id;
  final Function(Map<String, dynamic> tabletData) onSuccess;
  final Function(String)? onError;

  const FetchTreatmentTabletDetailsEvent(
    this.id, {
    required this.onSuccess,
    this.onError,
  });

  @override
  List<Object?> get props => [id];
}

class FetchTreatmentFullDetailsEvent extends MedicalTreatmentEvent {
  final String id;
  final Function(Map<String, dynamic> fullData) onSuccess;
  final Function(String)? onError;

  const FetchTreatmentFullDetailsEvent(
    this.id, {
    required this.onSuccess,
    this.onError,
  });

  @override
  List<Object?> get props => [id];
}
