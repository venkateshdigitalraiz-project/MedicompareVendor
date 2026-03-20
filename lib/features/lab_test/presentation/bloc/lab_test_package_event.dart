import 'package:equatable/equatable.dart';

abstract class LabTestPackageEvent extends Equatable {
  const LabTestPackageEvent();
  @override
  List<Object?> get props => [];
}

class LoadLabTestPackagesEvent extends LabTestPackageEvent {
  final int page;
  final String search;
  final String labTestId;
  final bool isLoadMore;

  const LoadLabTestPackagesEvent({
    this.page = 1,
    this.search = '',
    this.labTestId = '',
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [page, search, labTestId, isLoadMore];
}

class SearchLabTestPackagesEvent extends LabTestPackageEvent {
  final String query;
  const SearchLabTestPackagesEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class SelectLabTestForPackageFilterEvent extends LabTestPackageEvent {
  final String labTestId;
  const SelectLabTestForPackageFilterEvent(this.labTestId);
  @override
  List<Object?> get props => [labTestId];
}
