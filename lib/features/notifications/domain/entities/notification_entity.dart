import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;
  final String? platform;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
    this.platform,
  });

  @override
  List<Object?> get props => [id, title, message, read, createdAt, platform];
}

class NotificationPagination extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int pages;

  const NotificationPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  @override
  List<Object?> get props => [page, limit, total, pages];
}
