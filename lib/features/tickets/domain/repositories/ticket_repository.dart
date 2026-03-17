import '../../data/models/ticket_model.dart';

abstract class TicketRepository {
  Future<TicketModel> createTicket({
    required String subject,
    required String priority,
    required String message,
  });

  Future<List<TicketModel>> getTickets();

  Future<TicketMessage> sendMessage({
    required String ticketId,
    required String message,
  });
}
