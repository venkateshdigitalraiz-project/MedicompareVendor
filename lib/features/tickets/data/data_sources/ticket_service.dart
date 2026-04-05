import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/ticket_model.dart';

class TicketService {
  final ApiServiceRepository apiService;

  TicketService({required this.apiService});

  Future<TicketModel> createTicket({
    required String subject,
    required String priority,
    required String message,
  }) async {
    final response = await apiService.post(
      ApiEndpoints.createTicket,
      body: {
        'subject': subject,
        'priority': priority,
        'message': message,
      },
    );

    final decoded = jsonDecode(response.body);
    if (decoded['success'] == true) {
      return TicketModel.fromJson(decoded['data']['tickets']);
    } else {
      throw Exception(decoded['message'] ?? 'Failed to create ticket');
    }
  }

  Future<List<TicketModel>> getTickets() async {
    final response = await apiService.get(ApiEndpoints.listTickets);
    final decoded = jsonDecode(response.body);
    if (decoded['success'] == true) {
      final List ticketsJson = decoded['data']['tickets'];
      return ticketsJson.map((e) => TicketModel.fromJson(e)).toList();
    } else {
      throw Exception(decoded['message'] ?? 'Failed to fetch tickets');
    }
  }

  Future<TicketMessage> sendMessage({
    required String ticketId,
    required String message,
  }) async {
    final response = await apiService.post(
      ApiEndpoints.sendMessage,
      body: {
        'ticketId': ticketId,
        'message': message,
      },
    );

    final decoded = jsonDecode(response.body);
    if (decoded['success'] == true) {
      // API returns data: null on success as per provided reference
      return TicketMessage(
        id: '',
        ticketId: ticketId,
        sender: 'vendor',
        message: message,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      throw Exception(decoded['message'] ?? 'Failed to send message');
    }
  }
}
