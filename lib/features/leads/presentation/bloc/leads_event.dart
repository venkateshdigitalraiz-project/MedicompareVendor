import 'package:equatable/equatable.dart';

abstract class LeadsEvent extends Equatable {
  const LeadsEvent();

  @override
  List<Object?> get props => [];
}

class GetLeadsEvent extends LeadsEvent {
  final int page;
  final int limit;
  final String status;
  final String leadStage;
  final String search;

  const GetLeadsEvent({
    this.page = 1,
    this.limit = 10,
    this.status = '',
    this.leadStage = '',
    this.search = '',
  });

  @override
  List<Object?> get props => [page, limit, status, leadStage, search];
}
