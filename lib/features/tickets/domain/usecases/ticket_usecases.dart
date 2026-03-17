import '../../data/models/ticket_model.dart';
import '../repositories/ticket_repository.dart';

class CreateTicketUseCase {
  final TicketRepository repository;
  CreateTicketUseCase({required this.repository});

  Future<TicketModel> call({
    required String subject,
    required String priority,
    required String message,
  }) {
    return repository.createTicket(
      subject: subject,
      priority: priority,
      message: message,
    );
  }
}

class GetTicketsUseCase {
  final TicketRepository repository;
  GetTicketsUseCase({required this.repository});

  Future<List<TicketModel>> call() {
    return repository.getTickets();
  }
}

class SendMessageUseCase {
  final TicketRepository repository;
  SendMessageUseCase({required this.repository});

  Future<TicketMessage> call({
    required String ticketId,
    required String message,
  }) {
    return repository.sendMessage(
      ticketId: ticketId,
      message: message,
    );
  }
}
