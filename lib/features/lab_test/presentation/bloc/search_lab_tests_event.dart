import 'package:equatable/equatable.dart';

abstract class SearchLabTestsEvent extends Equatable {
  const SearchLabTestsEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChangedEvent extends SearchLabTestsEvent {
  final String query;

  const SearchQueryChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchEvent extends SearchLabTestsEvent {}
