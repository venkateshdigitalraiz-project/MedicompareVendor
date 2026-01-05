import 'package:MediCompare/auth/generate_ticket.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  String selectedStatus = "All";
  String searchQuery = "";

  final List<Map<String, String>> allTickets = [
    {
      "title": "Delivery Delayed",
      "id": "#TK-2840",
      "date": "Dec 27, 2024",
      "status": "Open",
    },
    {
      "title": "Payment Delay",
      "id": "#TK-2846",
      "date": "Dec 27, 2024",
      "status": "In Progress",
    },
    {
      "title": "App Login Problem",
      "id": "#TK-2845",
      "date": "Dec 26, 2024",
      "status": "Resolved",
    },
    {
      "title": "Wrong Order Delivered",
      "id": "#TK-2844",
      "date": "Dec 25, 2024",
      "status": "Open",
    },
    {
      "title": "Invoice Not Generated",
      "id": "#TK-2843",
      "date": "Dec 24, 2024",
      "status": "Resolved",
    },
    {
      "title": "Refund Not Received",
      "id": "#TK-2842",
      "date": "Dec 23, 2024",
      "status": "In Progress",
    },
    {
      "title": "Product Quality Issue",
      "id": "#TK-2841",
      "date": "Dec 22, 2024",
      "status": "Resolved",
    },
    {
      "title": "Product Quality Issue",
      "id": "#TK-2841",
      "date": "Dec 22, 2024",
      "status": "Resolved",
    },
  ];

  List<Map<String, String>> get filteredTickets {
    return allTickets.where((ticket) {
      final matchesSearch =
          ticket["title"]!.toLowerCase().contains(searchQuery.toLowerCase()) ||
              ticket["id"]!.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStatus =
          selectedStatus == "All" || ticket["status"] == selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int get totalCount => allTickets.length;
  int get openCount => allTickets.where((t) => t["status"] == "Open").length;
  int get resolvedCount =>
      allTickets.where((t) => t["status"] == "Resolved").length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff8046F1),
        elevation: 0,
        title: Text(
          "Ticket Lists",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Color(0xffffffff),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffE5E7EB)),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: "Search by Ticket ID or Title",
                  hintStyle: GoogleFonts.inter(fontSize: 12),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, size: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statCard(totalCount.toString(), "Total", Colors.deepPurple),
                const SizedBox(width: 8),
                _statCard(openCount.toString(), "Open", Colors.orange),
                const SizedBox(width: 8),
                _statCard(resolvedCount.toString(), "Resolved", Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _filterChip("All"),
                const SizedBox(width: 8),
                _filterChip("Open"),
                const SizedBox(width: 8),
                _filterChip("In Progress"),
                const SizedBox(width: 8),
                _filterChip("Resolved"),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredTickets.isEmpty
                  ? Center(
                      child: Text(
                        "No tickets found",
                        style: GoogleFonts.inter(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = filteredTickets[index];
                        return _ticketTile(
                          title: ticket["title"]!,
                          id: ticket["id"]!,
                          date: ticket["date"]!,
                          status: ticket["status"]!,
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return GenerateTicket();
                      },
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: Text(
                  "Generate New Ticket",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: GoogleFonts.inter(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String text) {
    final isSelected = selectedStatus == text;
    return GestureDetector(
      onTap: () {
        setState(() => selectedStatus = text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff7C3AED) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffE5E7EB)),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _ticketTile({
    required String title,
    required String id,
    required String date,
    required String status,
  }) {
    Color statusColor;
    switch (status) {
      case "Open":
        statusColor = Colors.orange;
        break;
      case "In Progress":
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  "$id • $date",
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(fontSize: 11, color: statusColor),
            ),
          ),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    );
  }
}
