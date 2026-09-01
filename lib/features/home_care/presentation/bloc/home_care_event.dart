import 'package:equatable/equatable.dart';
import 'package:MediCompare/features/home_care/data/models/home_care_model.dart';

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

class CreateHomeCareEvent extends HomeCareEvent {
  final Map<String, dynamic> payload;
  final Function onSuccess;
  final Function(String) onError;

  const CreateHomeCareEvent(this.payload,
      {required this.onSuccess, required this.onError});

  @override
  List<Object?> get props => [payload];
}

class UpdateHomeCareEvent extends HomeCareEvent {
  final String id;
  final Map<String, dynamic> payload;
  final Function onSuccess;
  final Function(String) onError;

  const UpdateHomeCareEvent(this.id, this.payload,
      {required this.onSuccess, required this.onError});

  @override
  List<Object?> get props => [id, payload];
}

class SearchHomeCareDropdownEvent extends HomeCareEvent {
  final String query;
  const SearchHomeCareDropdownEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FetchHomeCareDetailsEvent extends HomeCareEvent {
  final String id;
  final Function(HomeCareDropdownItem details) onSuccess;
  
  const FetchHomeCareDetailsEvent(this.id, {required this.onSuccess});

  @override
  List<Object?> get props => [id];
}
