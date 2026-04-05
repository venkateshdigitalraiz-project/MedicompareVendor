import 'package:equatable/equatable.dart';

class TicketModel extends Equatable {
  final String id;
  final String ticketNo;
  final String? vendorId;
  final String? adminId;
  final String? customerId;
  final String subject;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TicketMessage>? messages;

  const TicketModel({
    required this.id,
    required this.ticketNo,
    this.vendorId,
    this.adminId,
    this.customerId,
    required this.subject,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.messages,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['_id'] ?? '',
      ticketNo: json['ticketNo'] ?? '',
      vendorId: json['vendorId'],
      adminId: json['adminId'],
      customerId: json['customerId'],
      subject: json['subject'] ?? '',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'open',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((e) => TicketMessage.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'ticketNo': ticketNo,
      'vendorId': vendorId,
      'adminId': adminId,
      'customerId': customerId,
      'subject': subject,
      'priority': priority,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props =>
      [id, ticketNo, subject, status, priority, messages];
}

class TicketMessage extends Equatable {
  final String id;
  final String ticketId;
  final String? sendedId;
  final String sender;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TicketMessage({
    required this.id,
    required this.ticketId,
    this.sendedId,
    required this.sender,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['_id'] ?? '',
      ticketId: json['ticketId'] ?? '',
      sendedId: json['sendedId'],
      sender: json['sender'] ?? 'vendor',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'ticketId': ticketId,
      'sendedId': sendedId,
      'sender': sender,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, ticketId, message, sender, createdAt];
}
