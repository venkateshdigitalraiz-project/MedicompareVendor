import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final TextEditingController _medicineController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool isInStock = true;

  final List<String> medicineList = [
    "Ibuprofen",
    "Paracetamol",
    "Amoxicillin",
    "Cetirizine",
    "Aspirin",
    "Azithromycin",
  ];

  @override
  void initState() {
    super.initState();
    _medicineController.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _medicineController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showMedicineList() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: medicineList.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, index) {
            return ListTile(
              title: Text(
                medicineList[index],
                style: GoogleFonts.inter(fontSize: 14),
              ),
              onTap: () {
                _medicineController.text = medicineList[index];
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showClear =
        _focusNode.hasFocus || _medicineController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff8046f1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          "Add New Medicine",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 29),

              Text(
                "Medicine Information",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Please provide accurate information for the medicine",
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 29),

              Text("Medicine Name", style: GoogleFonts.inter(fontSize: 16)),
              const SizedBox(height: 7),

              /// SEARCH FIELD
              TextField(
                controller: _medicineController,
                focusNode: _focusNode,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Ex: Ibuprofen, paracetamol",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),

                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showClear)
                        GestureDetector(
                          onTap: () => _medicineController.clear(),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showMedicineList,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xff8046f1)),
                  ),
                ),
              ),

              SizedBox(height: 18),
              Text(
                "Variants",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Container with border radius
              Container(
                width: 365,
                //height: 412,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  border: Border.all(
                    color: Color(0xffE5E7EB),
                  ), // Optional border
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                        Text(
                          "Variant Name",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Icon(
                          Icons.delete_outline_sharp,
                          color: Color(0xffEB2727),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    _inputField(hint: "Enter the variant name"),
                    SizedBox(height: 5),
                    Text(
                      "Price",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    _inputField(hint: "Enter the variant price "),
                    SizedBox(height: 5),
                    Text(
                      "Quantity",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    _inputField(hint: "Enter the variant quantity"),
                    SizedBox(height: 5),
                    Text(
                      "Status",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // Inside the Container, after the Status Text
                    SizedBox(height: 6),
                    Row(
                      children: [
                        /// IN STOCK
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isInStock = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isInStock
                                  ? const Color(0xFF095D28)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isInStock
                                    ? const Color(0xFF095D28)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "In stock",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// OUT STOCK
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isInStock = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: !isInStock
                                  ? const Color(0xFFF7B2B2)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: !isInStock
                                    ? const Color(0xFFF7B2B2)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: !isInStock
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFFE5E7EB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Out stock",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Color(0xffEB3F3F),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 27),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 365,
                //height: 412,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  border: Border.all(
                    color: Color(0xffE5E7EB),
                  ), // Optional border
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       
                        Text(
                          "Variant Name",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Icon(
                          Icons.delete_outline_sharp,
                          color: Color(0xffEB2727),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    _inputField(hint: "Enter the variant name"),
                    SizedBox(height: 5),
                    Text(
                      "Price",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    _inputField(hint: "Enter the variant price "),
                    SizedBox(height: 5),
                    Text(
                      "Quantity",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    _inputField(hint: "Enter the variant quantity"),
                    SizedBox(height: 5),
                    Text(
                      "Status",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // Inside the Container, after the Status Text
                    SizedBox(height: 6),
                    Row(
                      children: [
                        /// IN STOCK
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isInStock = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isInStock
                                  ? const Color(0xFF095D28)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isInStock
                                    ? const Color(0xFF095D28)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "In stock",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// OUT STOCK
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isInStock = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: !isInStock
                                  ? const Color(0xFFF7B2B2)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: !isInStock
                                    ? const Color(0xFFF7B2B2)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: !isInStock
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFFE5E7EB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Out stock",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Color(0xffEB3F3F),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 27),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Spacer(),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED), // Purple
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.add, color: Colors.white, size: 20),
                      onPressed: () {
                        // Add variant action
                        
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28),
              Row(
                children: [
                  /// CANCEL
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xff8046f1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(
                          color: const Color(0xff8046f1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// ADD MEDICINE
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff8046f1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Add Medicine",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 27),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _inputField({required String hint}) {
    return SizedBox(
      height: 46,
      child: TextField(
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
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
