import 'package:equatable/equatable.dart';

abstract class AmbulanceEvent extends Equatable {
  const AmbulanceEvent();

  @override
  List<Object?> get props => [];
}

class GetAmbulanceListEvent extends AmbulanceEvent {
  final int page;
  final int limit;
  final String categoryId;
  final String search;
  final bool isLoadMore;

  const GetAmbulanceListEvent({
    this.page = 1,
    this.limit = 10,
    this.categoryId = '',
    this.search = '',
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [page, limit, categoryId, search, isLoadMore];
}

class GetAmbulanceFormOptionsEvent extends AmbulanceEvent {
  const GetAmbulanceFormOptionsEvent();
}

class SearchAmbulanceNamesEvent extends AmbulanceEvent {
  final String query;
  const SearchAmbulanceNamesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateAmbulanceEvent extends AmbulanceEvent {
  final Map<String, dynamic> payload;
  const CreateAmbulanceEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}

class UpdateAmbulanceEvent extends AmbulanceEvent {
  final String id;
  final Map<String, dynamic> payload;
  const UpdateAmbulanceEvent(this.id, this.payload);

  @override
  List<Object?> get props => [id, payload];
}

class DeleteAmbulanceEvent extends AmbulanceEvent {
  final String id;
  const DeleteAmbulanceEvent(this.id);

  @override
  List<Object?> get props => [id];
}
