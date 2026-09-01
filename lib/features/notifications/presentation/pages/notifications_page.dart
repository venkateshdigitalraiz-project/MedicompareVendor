import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/core/utils/core_injection.dart';
import '../bloc/notifications_bloc.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<NotificationsBloc>();
    if (bloc.state is! NotificationsLoaded) {
      bloc.add(LoadNotificationsEvent(refresh: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFB),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            "Notifications",
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<NotificationsBloc>().add(MarkAllNotificationsReadEvent());
              },
              child: Text(
                "Mark all as read",
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        body: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationsError) {
              return Center(child: Text(state.message));
            } else if (state is NotificationsLoaded) {
              if (state.notifications.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<NotificationsBloc>().add(LoadNotificationsEvent(refresh: true)),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      state.notifications.length + (state.hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == state.notifications.length) {
                      context.read<NotificationsBloc>().add(LoadNotificationsEvent());
                      return const Center(
                          child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator()));
                    }
                    final notification = state.notifications[index];
                    return _buildNotificationCard(notification);
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationsBloc>().add(LoadNotificationsEvent(refresh: true));
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[100]!)),
                      child: Icon(Icons.notifications_none,
                          size: 64, color: Colors.grey[300]),
                    ),
                    const SizedBox(height: 24),
                    Text("No notifications yet",
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text("We'll notify you when something important happens",
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationEntity notification) {
    bool isUnread = !notification.read;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUnread
            ? Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5)
            : Border.all(color: Colors.grey[100]!),
        boxShadow: [
          if (isUnread)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (notification.title.toLowerCase().contains('order'))
                  ? const Color(0xFFF1F4FF)
                  : (notification.title.toLowerCase().contains('status')
                      ? const Color(0xFFF1FFF4)
                      : const Color(0xFFFFF7F1)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              (notification.title.toLowerCase().contains('order'))
                  ? Icons.shopping_bag_outlined
                  : (notification.title.toLowerCase().contains('status')
                      ? Icons.check_circle_outline
                      : Icons.info_outline),
              size: 20,
              color: (notification.title.toLowerCase().contains('order'))
                  ? const Color(0xFF3F51B5)
                  : (notification.title.toLowerCase().contains('status')
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF57C00)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.w600,
                            color: Colors.grey[900]),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.grey[600], height: 1.4),
                ),
                const SizedBox(height: 12),
                Text(
                  DateFormat('MMM d, h:mm a').format(notification.createdAt),
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
