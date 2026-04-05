import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../../data/models/ticket_model.dart';
import 'tickets_event.dart';
import 'tickets_state.dart';

class TicketsBloc extends Bloc<TicketsEvent, TicketsState> {
  final TicketRepository ticketRepository;

  TicketsBloc({required this.ticketRepository}) : super(TicketsInitial()) {
    on<LoadTicketsEvent>((event, emit) async {
      final currentState = state;
      TicketModel? selectedTicket;
      if (currentState is TicketsLoaded) {
        selectedTicket = currentState.selectedTicket;
      } else {
        emit(TicketsLoading());
      }

      try {
        final tickets = await ticketRepository.getTickets();

        // Find the selected ticket in the new list to get updated messages
        TicketModel? newSelected;
        if (selectedTicket != null) {
          try {
            newSelected = tickets.firstWhere((t) => t.id == selectedTicket!.id);
          } catch (_) {
            newSelected = null;
          }
        }

        emit(TicketsLoaded(tickets: tickets, selectedTicket: newSelected));
      } catch (e) {
        emit(TicketsError(message: e.toString()));
      }
    });

    on<CreateTicketEvent>((event, emit) async {
      try {
        await ticketRepository.createTicket(
          subject: event.subject,
          priority: event.priority,
          message: event.message,
        );
        emit(TicketActionSuccess("Ticket created successfully"));
        add(LoadTicketsEvent());
      } catch (e) {
        emit(TicketsError(message: e.toString()));
      }
    });

    on<SendMessageEvent>((event, emit) async {
      final currentState = state;
      if (currentState is TicketsLoaded) {
        try {
          await ticketRepository.sendMessage(
            ticketId: event.ticketId,
            message: event.message,
          );
          add(LoadTicketsEvent());
        } catch (e) {
          emit(TicketsError(message: e.toString()));
        }
      }
    });

    on<SelectTicketEvent>((event, emit) {
      final currentState = state;
      if (currentState is TicketsLoaded) {
        emit(TicketsLoaded(
          tickets: currentState.tickets,
          selectedTicket: event.ticket,
        ));
      }
    });
  }
}
