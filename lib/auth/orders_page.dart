import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:MediCompare/auth/mainprofile.dart';
import 'package:MediCompare/auth/ticket_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  int _selectedIndex = 0;

  final List<String> _statusList = ["All", "Active", "Pending", "Completed"];

  final List<Map<String, dynamic>> ordersList = [
    {
      "orderId": "#622318248726487",
      "name": "Priya Sharma",
      "email": "priya.sharma@email.com",
      "phone": "+91 98765 43210",
      "city": "Mumbai",
      "amount": "₹2,500.00",
      "status": "Confirmed",
      "date": "Dec 15, 2024 ",
      "time": "2:30 PM",
      "tags": ["Paracetamol", "Vitamin D3", "Cough Syrup"],
    },
    {
      "orderId": "#622318248726487",
      "name": "Rajesh Kumar",
      "email": "rajesh.k@email.com",
      "phone": "+91 87654 32109",
      "city": "Delhi",
      "amount": "₹4,200.00",
      "status": "Pending",
      "date": "Dec 16, 2024",
      "time": "10:00 AM",
      "tags": ["Insulin", "Glucometer"],
    },
    {
      "orderId": "#622318248726487",
      "name": "Anita Patel",
      "email": "anita.patel@email.com",
      "phone": "+91 76543 21098",
      "city": "Ahmedabad",
      "amount": "₹1,850.00",
      "status": "Completed",
      "date": "Dec 14, 2024",
      "time": "4:15 PM",
      "tags": ["Antibiotics", "Pain Relief", "Bandages"],
    },

    {
      "orderId": "#622318248726487",
      "name": "Suresh Gupta",
      "email": "suresh.g@email.com",
      "phone": "+91 65432 10987",
      "city": " Pune",
      "amount": "₹3,750.00",
      "status": "Confirmed",
      "date": "Dec 17, 2024",
      "time": "11:30 AM",
      "tags": ["Blood Pressure", "Heart Medication"],
    },
    {
      "orderId": "#622318248726487",
      "name": "Meera Singh",
      "email": "meera.singh@email.com",
      "phone": "++91 54321 09876",
      "city": " Bangalore",
      "amount": "₹1,200.00",
      "status": "Pending",
      "date": "Dec 18, 2024 ",
      "time": "9:00 AM",
      "tags": ["Multivitamins", "Calcium", "Iron Tablets"],
    },
  ];
  Color _statusBgColor(String status) {
    switch (status) {
      case "Confirmed":
        return const Color(0xFFDBEAFE); // light blue
      case "Pending":
        return const Color(0xFFFFEDD5); // light orange
      case "Completed":
        return const Color(0xFFDCFCE7); // light green
      default:
        return const Color(0xFFF3F4F6); // grey
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case "Confirmed":
        return const Color(0xFF2563EB); // blue
      case "Pending":
        return const Color(0xFFEA580C); // orange
      case "Completed":
        return const Color(0xFF16A34A); // green
      default:
        return const Color(0xFF374151);
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    final selectedStatus = _statusList[_selectedIndex];

    List<Map<String, dynamic>> filtered = ordersList;

    // STATUS FILTER
    if (selectedStatus == "Active") {
      filtered = filtered
          .where((order) => order["status"] == "Confirmed")
          .toList();
    } else if (selectedStatus != "All") {
      filtered = filtered
          .where((order) => order["status"] == selectedStatus)
          .toList();
    }

    // SEARCH FILTER
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        final query = _searchQuery.toLowerCase();
        return order["orderId"].toLowerCase().contains(query) ||
            order["name"].toLowerCase().contains(query) ||
            order["email"].toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Orders",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 27),

            // 🔍 Search Input
            _inputField(
              hint: "Search by order ID, customer name, or email",
              icon: Icons.search,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // 🔄 Status Filter (Horizontal Scroll)
            SizedBox(
              height: 40,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_statusList.length, (index) {
                    final bool isSelected = _selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF000000)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusList[index],
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 17),

            // Orders / Notifications list placeholder
            Expanded(
              child: ListView.builder(
                itemCount: _filteredOrders.length,

                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB), // light grey border
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔝 Order ID & Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order ID: ${order["orderId"]}",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: Color(0xff2B2E35),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusBgColor(order["status"]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order["status"],
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: _statusTextColor(order["status"]),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Divider(
                          color: Color(0xFFE5E7EB), // light grey
                          thickness: 1,
                        ),
                        const SizedBox(height: 8.5),

                        // 👤 Name & Amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order["name"],
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              order["amount"],
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // 📧 Email
                        Text(
                          order["email"],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff6B7280),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // 📍 Phone & City
                        Text(
                          "${order["phone"]} • ${order["city"]}",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff6B7280),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 🏷️ Tags
                        Wrap(
                          spacing: 8,
                          children: List.generate(order["tags"].length, (i) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order["tags"][i],
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF7C3AED),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 10),

                        // 📅 Date & Time
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${order["date"]} • ${order["time"]}",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff6B7280),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 🎟️ Ticket Button
                      ],
                    ),
                  );
                },
              ),
            ),
            
            
           
          ],
        ),
      ),
    );
  }

  // 🔁 Reusable Input Field
  static Widget _inputField({
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
          ),
        ),
      ),
    );
  }
}
