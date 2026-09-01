import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/models/notification_model.dart';

// --- Events ---
abstract class NotificationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationsEvent {
  final bool refresh;
  LoadNotificationsEvent({this.refresh = false});
  @override
  List<Object?> get props => [refresh];
}

class MarkAllNotificationsReadEvent extends NotificationsEvent {}

// --- State ---
abstract class NotificationsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final NotificationPagination pagination;
  final bool hasMore;

  NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    required this.pagination,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, pagination, hasMore];
}

class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final ApiServiceRepository apiService;
  int _currentPage = 1;
  final int _limit = 30;

  NotificationsBloc(this.apiService) : super(NotificationsInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<MarkAllNotificationsReadEvent>(_onMarkAllRead);
  }

  Future<void> _onLoadNotifications(
      LoadNotificationsEvent event, Emitter<NotificationsState> emit) async {
    if (event.refresh) {
      _currentPage = 1;
      emit(NotificationsLoading());
    }

    try {
      final response =
          await apiService.get(ApiEndpoints.notificationList, queryParameters: {
        'page': _currentPage.toString(),
        'limit': _limit.toString(),
      });

      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        final data = json['data'];
        final List<dynamic> notifList = data['notifications'] ?? [];
        final items =
            notifList.map((n) => NotificationModel.fromJson(n)).toList();
        final unreadCount = data['unreadCount'] ?? 0;
        final pagination =
            NotificationModel.paginationFromJson(data['pagination'] ?? {});

        List<NotificationEntity> updatedList = event.refresh
            ? []
            : (state is NotificationsLoaded
                ? (state as NotificationsLoaded).notifications
                : []);
        updatedList.addAll(items);

        final hasMore = _currentPage < pagination.pages;
        if (hasMore) _currentPage++;

        emit(NotificationsLoaded(
          notifications: updatedList,
          unreadCount: unreadCount,
          pagination: pagination,
          hasMore: hasMore,
        ));
      } else {
        emit(NotificationsError(
            json['message'] ?? 'Failed to load notifications'));
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkAllRead(MarkAllNotificationsReadEvent event,
      Emitter<NotificationsState> emit) async {
    try {
      final response =
          await apiService.post(ApiEndpoints.markAllNotificationsRead);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (state is NotificationsLoaded) {
          final loadedState = state as NotificationsLoaded;
          final updated = loadedState.notifications.map((n) {
            return NotificationEntity(
              id: n.id,
              title: n.title,
              message: n.message,
              read: true,
              createdAt: n.createdAt,
              platform: n.platform,
            );
          }).toList();
          emit(NotificationsLoaded(
            notifications: updated,
            unreadCount: 0,
            hasMore: loadedState.hasMore,
            pagination: loadedState.pagination,
          ));
        }
      }
    } catch (_) {}
  }
}
