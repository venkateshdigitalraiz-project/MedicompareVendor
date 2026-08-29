import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:MediCompare/core/constants/app_colors.dart';
import '../bloc/edit_lead_bloc.dart';
import '../bloc/edit_lead_event.dart';
import '../bloc/edit_lead_state.dart';
import '../../lab_test_injection.dart';

class EditLeadScreen extends StatelessWidget {
  final String productId;

  const EditLeadScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LabTestInjection.provideEditLeadBloc()
        ..add(LoadLabTestDetailsEvent(productId)),
      child: _EditLeadScreenContent(productId: productId),
    );
  }
}

class _EditLeadScreenContent extends StatefulWidget {
  final String productId;
  const _EditLeadScreenContent({required this.productId});

  @override
  State<_EditLeadScreenContent> createState() => _EditLeadScreenContentState();
}

class _EditLeadScreenContentState extends State<_EditLeadScreenContent> {
  final _formKey = GlobalKey<FormState>();

  final _searchController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _discountTypeController = TextEditingController();
  final _facilitiesController = TextEditingController();
  String _selectedStatus = 'active';
  String? _tabletId;

  @override
  void dispose() {
    _searchController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _discountTypeController.dispose();
    _facilitiesController.dispose();
    super.dispose();
  }

  void _populateForm(EditLeadLoaded state) {
    final product = state.product;
    _tabletId = product.details.id;
    _searchController.text = product.details.name;
    _priceController.text = product.price % 1 == 0
        ? product.price.toInt().toString()
        : product.price.toStringAsFixed(2);
    _discountController.text = product.discountPrice % 1 == 0
        ? product.discountPrice.toInt().toString()
        : product.discountPrice.toStringAsFixed(2);
    // Assuming product model has discountType and facilities if needed.
    // Wait, the existing LabTestItem model might not map discountType directly
    // if it wasn't there before, but the prompt mentioned it.
    // I will leave them empty or map if they exist in LabTestItem.
    // product.status is there.
    _selectedStatus =
        product.status.toLowerCase() == 'inactive' ? 'inactive' : 'active';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Lab Test",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Body
            Flexible(
              child: BlocConsumer<EditLeadBloc, EditLeadState>(
                listener: (context, state) {
                  if (state is EditLeadLoaded) {
                    _populateForm(state);
                  } else if (state is EditLeadUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Lab test updated successfully!'),
                          backgroundColor: Colors.green),
                    );
                    Navigator.pop(context, true);
                  } else if (state is EditLeadError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(state.message), backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is EditLeadLoading || state is EditLeadInitial) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is EditLeadError) {
                    return Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(state.message,
                                style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    );
                  }

          if (state is EditLeadLoaded) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFF5F3FF),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.science_outlined,
                                      color: AppColors.primary, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Edit Lab Test',
                                        style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1E1B4B)),
                                      ),
                                      Text(
                                        'Update the lab test details below',
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Lab Test Information",
                                      style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E1B4B))),
                                  Text(
                                      "Please provide accurate information for the lab test",
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey[500])),
                                  const SizedBox(height: 20),
                                  _buildLabel("Test Name",
                                      isRequired: true,
                                      icon: Icons.science_outlined),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _searchController,
                                    enabled: false,
                                    style: GoogleFonts.inter(
                                        fontSize: 13, color: Colors.grey[600]),
                                    decoration: _inputDecoration(
                                            hint: "Search and select a test...")
                                        .copyWith(
                                      fillColor: Colors.grey[50],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: _buildInputField(
                                              "Price (₹)",
                                              _priceController,
                                              Icons.currency_rupee)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: _buildInputField(
                                              "Discount Price (₹)",
                                              _discountController,
                                              Icons.local_offer_outlined)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildLabel("Status",
                                                isRequired: true,
                                                icon:
                                                    Icons.check_circle_outline),
                                            const SizedBox(height: 8),
                                            DropdownButtonFormField<String>(
                                              value: _selectedStatus,
                                              isExpanded: true,
                                              decoration: _inputDecoration(
                                                  hint: "Status"),
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: Colors.black87),
                                              items: [
                                                DropdownMenuItem(
                                                    value: 'active',
                                                    child: Text("Active",
                                                        style:
                                                            GoogleFonts.inter(
                                                                fontSize: 13))),
                                                DropdownMenuItem(
                                                    value: 'inactive',
                                                    child: Text("Inactive",
                                                        style:
                                                            GoogleFonts.inter(
                                                                fontSize: 13))),
                                              ],
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() =>
                                                      _selectedStatus = value);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(16)),
                                border: Border(
                                    top: BorderSide(color: Colors.grey[200]!))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Cancel",
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: const Color(0xFF1E1B4B),
                                          fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  height: 44,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        final Map<String, dynamic> data = {
                                          "description": "<p><br></p>",
                                          "discount": double.tryParse(_discountController.text) ?? 0,
                                          "fastingRequired": "no",
                                          "name": _tabletId,
                                          "normalRange": "",
                                          "price": double.tryParse(_priceController.text) ?? 0,
                                        };
                                        context.read<EditLeadBloc>().add(
                                            UpdateLabTestDetailsEvent(
                                                widget.productId, data));
                                      }
                                    },
                                    icon: state is EditLeadUpdating
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2))
                                        : const Icon(Icons.science_outlined,
                                            size: 16),
                                    label: Text(
                                        state is EditLeadUpdating
                                            ? "Updating..."
                                            : "Update Lab Test",
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryDark,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

            return const SizedBox.shrink();
          },
        ),
      ),
    ],
  ),
),
);
}

  Widget _buildInputField(
      String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: true, icon: icon),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.inter(fontSize: 13),
          decoration: _inputDecoration(hint: "0.00"),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false, IconData? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6)
        ],
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E1B4B)),
          ),
        ),
        if (isRequired)
          Text(" *",
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red)),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!)),
    );
  }
}
