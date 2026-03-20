import 'package:equatable/equatable.dart';

abstract class DiagnosticEvent extends Equatable {
  const DiagnosticEvent();
  @override
  List<Object?> get props => [];
}

class LoadDiagnosticCategoriesEvent extends DiagnosticEvent {
  const LoadDiagnosticCategoriesEvent();
}

class LoadDiagnosticsEvent extends DiagnosticEvent {
  final int page;
  final String categoryId;
  final String search;
  final bool isLoadMore;

  const LoadDiagnosticsEvent({
    this.page = 1,
    this.categoryId = '',
    this.search = '',
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [page, categoryId, search, isLoadMore];
}

class SelectDiagnosticCategoryEvent extends DiagnosticEvent {
  final String categoryId;
  const SelectDiagnosticCategoryEvent(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class SearchDiagnosticsEvent extends DiagnosticEvent {
  final String query;
  const SearchDiagnosticsEvent(this.query);
  @override
  List<Object?> get props => [query];
}
