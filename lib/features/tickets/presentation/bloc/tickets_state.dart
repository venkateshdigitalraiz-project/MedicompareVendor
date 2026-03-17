import 'package:equatable/equatable.dart';
import '../../data/models/ticket_model.dart';

abstract class TicketsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TicketsInitial extends TicketsState {}

class TicketsLoading extends TicketsState {}

class TicketsLoaded extends TicketsState {
  final List<TicketModel> tickets;
  final TicketModel? selectedTicket;

  TicketsLoaded({required this.tickets, this.selectedTicket});

  @override
  List<Object?> get props => [tickets, selectedTicket];

  TicketsLoaded copyWith({
    List<TicketModel>? tickets,
    TicketModel? selectedTicket,
  }) {
    return TicketsLoaded(
      tickets: tickets ?? this.tickets,
      selectedTicket: selectedTicket ?? this.selectedTicket,
    );
  }
}

class TicketsError extends TicketsState {
  final String message;

  TicketsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TicketActionSuccess extends TicketsState {
  final String message;
  TicketActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
