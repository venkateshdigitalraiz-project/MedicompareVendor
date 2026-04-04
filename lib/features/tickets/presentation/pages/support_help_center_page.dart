import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/tickets/data/models/ticket_model.dart';
import 'package:MediCompare/features/tickets/presentation/bloc/tickets_bloc.dart';
import 'package:MediCompare/features/tickets/presentation/bloc/tickets_event.dart';
import 'package:MediCompare/features/tickets/presentation/bloc/tickets_state.dart';
import 'package:MediCompare/features/tickets/presentation/widgets/create_ticket_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SupportHelpCenterPage extends StatefulWidget {
  const SupportHelpCenterPage({super.key});

  @override
  State<SupportHelpCenterPage> createState() => _SupportHelpCenterPageState();
}

class _SupportHelpCenterPageState extends State<SupportHelpCenterPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TicketsBloc>().add(LoadTicketsEvent());
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showCreateTicket() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateTicketBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            final state = context.read<TicketsBloc>().state;
            if (state is TicketsLoaded && 
                state.selectedTicket != null && 
                MediaQuery.of(context).size.width <= 700) {
              context.read<TicketsBloc>().add(SelectTicketEvent(null));
            } else {
              context.pop();
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Support & Help Center",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Chat with support team and manage your tickets",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: _showCreateTicket,
              icon: const Icon(Icons.add, size: 18, color: AppColors.primaryDark),
              label: Text("New Ticket", 
                style: GoogleFonts.inter(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<TicketsBloc, TicketsState>(
        builder: (context, state) {
          if (state is TicketsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TicketsError) {
            return Center(child: Text(state.message));
          } else if (state is TicketsLoaded) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 700) {
                  return _buildDualPane(context, state);
                } else {
                  return _buildMobileView(context, state);
                }
              },
            );
          }
          return const Center(child: Text("Initializing..."));
        },
      ),
    );
  }

  Widget _buildDualPane(BuildContext context, TicketsLoaded state) {
    return Row(
      children: [
        // Sidebar
        SizedBox(
          width: 300,
          child: _buildTicketList(state),
        ),
        const VerticalDivider(width: 1),
        // Chat Area
        Expanded(
          child: _buildChatArea(state.selectedTicket),
        ),
      ],
    );
  }

  Widget _buildMobileView(BuildContext context, TicketsLoaded state) {
    if (state.selectedTicket != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          context.read<TicketsBloc>().add(SelectTicketEvent(null));
        },
        child: _buildChatArea(state.selectedTicket),
      );
    }
    return _buildTicketList(state);
  }

  Widget _buildTicketList(TicketsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                "My Tickets",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.tickets.length.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.tickets.isEmpty 
            ? Center(child: Text("No tickets found", style: GoogleFonts.inter(color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.tickets.length,
                itemBuilder: (context, index) {
                  final ticket = state.tickets[index];
                  final isSelected = state.selectedTicket?.id == ticket.id;
                  return _buildTicketCard(ticket, isSelected);
                },
              ),
        ),
      ],
    );
  }

  Widget _buildTicketCard(TicketModel ticket, bool isSelected) {
    return GestureDetector(
      onTap: () {
        context.read<TicketsBloc>().add(SelectTicketEvent(ticket));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ticket.subject,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1B4B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat('h:mm a').format(ticket.createdAt),
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Ticket ID: ${ticket.ticketNo}",
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildBadge(ticket.status, _getStatusColor(ticket.status)),
                const SizedBox(width: 8),
                _buildBadge(ticket.priority, _getPriorityColor(ticket.priority), isLight: true),
              ],
            ),
            if (ticket.messages != null && ticket.messages!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                ticket.messages!.last.message,
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF4B5563)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {bool isLight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildChatArea(TicketModel? ticket) {
    if (ticket == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Select a ticket to view conversation",
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Ticket Info Header (Chat)
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFF9FAFF),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [

                        Text(
                          ticket.subject,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1B4B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildBadge(ticket.status, _getStatusColor(ticket.status)),
                        const SizedBox(width: 8),
                        _buildBadge(ticket.priority, _getPriorityColor(ticket.priority), isLight: true),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Ticket ID: ${ticket.ticketNo}",
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Chat List
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ticket.messages?.length ?? 0,
              itemBuilder: (context, index) {
                final message = ticket.messages![index];
                final isMe = message.sender == 'vendor';
                return _buildChatBubble(message, isMe);
              },
            ),
          ),
        ),
        // Input Area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      hintStyle: GoogleFonts.inter(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _handleSend(ticket.id),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _handleSend(ticket.id),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Press Enter to send",
            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
          ),
        )
      ],
    );
  }

  Widget _buildChatBubble(TicketMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFF3E8FF),
                  child: Icon(Icons.support_agent, size: 16, color: Color(0xFF8B5CF6)),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF7C3AED) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.message,
                    style: GoogleFonts.inter(
                      color: isMe ? Colors.white : const Color(0xFF1F2937),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFF3E8FF),
                  child: Icon(Icons.person_outline, size: 16, color: Color(0xFF8B5CF6)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              DateFormat('h:mm a').format(message.createdAt),
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _handleSend(String ticketId) {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<TicketsBloc>().add(SendMessageEvent(
        ticketId: ticketId,
        message: _messageController.text.trim(),
      ));
      _messageController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.blue;
      case 'closed': return Colors.green;
      case 'resolved': return Colors.green;
      case 'pending': return Colors.orange;
      default: return Colors.blue;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.blue;
    }
  }
}
