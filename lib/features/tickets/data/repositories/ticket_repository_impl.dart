import '../../domain/repositories/ticket_repository.dart';
import '../data_sources/ticket_service.dart';
import '../models/ticket_model.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketService ticketService;

  TicketRepositoryImpl({required this.ticketService});

  @override
  Future<TicketModel> createTicket({
    required String subject,
    required String priority,
    required String message,
  }) async {
    return await ticketService.createTicket(
      subject: subject,
      priority: priority,
      message: message,
    );
  }

  @override
  Future<List<TicketModel>> getTickets() async {
    return await ticketService.getTickets();
  }

  @override
  Future<TicketMessage> sendMessage({
    required String ticketId,
    required String message,
  }) async {
    return await ticketService.sendMessage(
      ticketId: ticketId,
      message: message,
    );
  }
}
