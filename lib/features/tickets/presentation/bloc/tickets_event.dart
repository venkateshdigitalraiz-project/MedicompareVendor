import 'package:equatable/equatable.dart';
import '../../data/models/ticket_model.dart';

abstract class TicketsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTicketsEvent extends TicketsEvent {}

class CreateTicketEvent extends TicketsEvent {
  final String subject;
  final String priority;
  final String message;

  CreateTicketEvent({
    required this.subject,
    required this.priority,
    required this.message,
  });

  @override
  List<Object?> get props => [subject, priority, message];
}

class SendMessageEvent extends TicketsEvent {
  final String ticketId;
  final String message;

  SendMessageEvent({
    required this.ticketId,
    required this.message,
  });

  @override
  List<Object?> get props => [ticketId, message];
}

class SelectTicketEvent extends TicketsEvent {
  final TicketModel? ticket;

  SelectTicketEvent(this.ticket);

  @override
  List<Object?> get props => [ticket];
}
