import '../../core/utils/core_injection.dart';
import 'data/data_sources/ticket_service.dart';
import 'data/repositories/ticket_repository_impl.dart';
import 'domain/repositories/ticket_repository.dart';
import 'domain/usecases/ticket_usecases.dart';
import 'presentation/bloc/tickets_bloc.dart';

class TicketsInjection {
  static TicketService provideTicketService() {
    return TicketService(
      apiService: CoreInjection.provideApiService(),
    );
  }

  static TicketRepository provideTicketRepository() {
    return TicketRepositoryImpl(
      ticketService: provideTicketService(),
    );
  }

  static GetTicketsUseCase provideGetTicketsUseCase() {
    return GetTicketsUseCase(repository: provideTicketRepository());
  }

  static CreateTicketUseCase provideCreateTicketUseCase() {
    return CreateTicketUseCase(repository: provideTicketRepository());
  }

  static SendMessageUseCase provideSendMessageUseCase() {
    return SendMessageUseCase(repository: provideTicketRepository());
  }

  static TicketsBloc provideTicketsBloc() {
    return TicketsBloc(
      ticketRepository: provideTicketRepository(),
    );
  }
}
