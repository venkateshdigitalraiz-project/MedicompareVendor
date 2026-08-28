import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/medical_equipment_entity.dart';
import '../../domain/usecases/search_tablets_usecase.dart';
import '../../domain/usecases/update_medical_equipment_usecase.dart';
import '../../medical_equipment_injection.dart';

class EditMedicalEquipmentPage extends StatefulWidget {
  final MedicalEquipmentItem item;
  final VoidCallback? onSuccess;

  const EditMedicalEquipmentPage({
    super.key,
    required this.item,
    this.onSuccess,
  });

  @override
  State<EditMedicalEquipmentPage> createState() =>
      _EditMedicalEquipmentPageState();
}

class _EditMedicalEquipmentPageState extends State<EditMedicalEquipmentPage> {
  final _formKey = GlobalKey<FormState>();
  final SearchTabletsUseCase _searchTabletsUseCase =
      MedicalEquipmentInjection.provideSearchTabletsUseCase();
  final UpdateMedicalEquipmentUseCase _updateUseCase =
      MedicalEquipmentInjection.provideUpdateUseCase();

  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _depositController;
  late final TextEditingController _returnChargeController;
  late final TextEditingController _serviceChargeController;
  late final TextEditingController _rentController;

  String _selectedStatus = 'active';
  String? _selectedTabletId;
  String? _selectedTabletName;
  String? _selectedCategory;
  bool _isSubmitting = false;
  bool _isLoadingTablets = true;

  List<MedicalEquipmentDropdownItem> _tablets = [];

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _priceController = TextEditingController(
      text: item.price % 1 == 0
          ? item.price.toInt().toString()
          : item.price.toStringAsFixed(2),
    );
    _discountController = TextEditingController(
      text: item.discountPrice % 1 == 0
          ? item.discountPrice.toInt().toString()
          : item.discountPrice.toStringAsFixed(2),
    );
    _depositController = TextEditingController(
      text: (item.fixedDeposit ?? 0) % 1 == 0
          ? (item.fixedDeposit ?? 0).toInt().toString()
          : (item.fixedDeposit ?? 0).toStringAsFixed(2),
    );
    _returnChargeController = TextEditingController(
      text: (item.returnCharge ?? 0) % 1 == 0
          ? (item.returnCharge ?? 0).toInt().toString()
          : (item.returnCharge ?? 0).toStringAsFixed(2),
    );
    _serviceChargeController = TextEditingController(
      text: (item.serviceCharges ?? 0) % 1 == 0
          ? (item.serviceCharges ?? 0).toInt().toString()
          : (item.serviceCharges ?? 0).toStringAsFixed(2),
    );
    _rentController = TextEditingController(
      text: (item.perDayRent ?? 0) % 1 == 0
          ? (item.perDayRent ?? 0).toInt().toString()
          : (item.perDayRent ?? 0).toStringAsFixed(2),
    );

    _selectedStatus =
        item.status.toLowerCase() == 'inactive' ? 'inactive' : 'active';
    _selectedTabletId = item.details.id;
    _selectedTabletName = item.details.name;
    _selectedCategory = item.details.subcategory?.name;

    _loadTablets();
  }

  Future<void> _loadTablets() async {
    setState(() => _isLoadingTablets = true);
    try {
      final results = await _searchTabletsUseCase('');
      if (mounted) {
        setState(() {
          _tablets = results;
          // If current equipment not in results, prepend it so dropdown is fully populated
          if (_selectedTabletId != null &&
              !_tablets.any((t) => t.id == _selectedTabletId)) {
            _tablets.insert(
              0,
              MedicalEquipmentDropdownItem(
                id: _selectedTabletId!,
                name: _selectedTabletName ?? 'Medical Equipment',
                subcategory: widget.item.details.subcategory,
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading tablets: $e");
    } finally {
      if (mounted) setState(() => _isLoadingTablets = false);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    _depositController.dispose();
    _returnChargeController.dispose();
    _serviceChargeController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTabletId == null || _selectedTabletId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select medical equipment name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final payload = {
        'name': _selectedTabletId,
        'category': _selectedCategory ?? widget.item.details.subcategory?.name ?? 'General',
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'discount': double.tryParse(_discountController.text) ?? 0.0,
        'fixedDeposit': double.tryParse(_depositController.text) ?? 0.0,
        'returnCharge': double.tryParse(_returnChargeController.text) ?? 0.0,
        'serviceCharges': double.tryParse(_serviceChargeController.text) ?? 0.0,
        'perDayRent': double.tryParse(_rentController.text) ?? 0.0,
        'status': _selectedStatus,
        'brand': widget.item.details.brand ?? '',
        'model': widget.item.details.model ?? '',
        'description': widget.item.details.description.isNotEmpty
            ? widget.item.details.description
            : 'Medical equipment',
        'interest': null,
      };

      await _updateUseCase(widget.item.id, payload);

      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical equipment updated successfully'),
            backgroundColor: Color(0xFF15803D),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('ServerException: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E1B4B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Medical Equipment",
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E1B4B),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.health_and_safety_outlined,
                                color: Color(0xFF6B48FF),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Edit Medical Equipment",
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E1B4B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Update the medical equipment details below",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.grey),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Section Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Medical Equipment Information",
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E1B4B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Please provide accurate information for the medical equipment",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Form Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            // Row 1: Name + Price
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildEquipmentDropdown()),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildInputField(
                                    label: "Price (₹)",
                                    controller: _priceController,
                                    icon: Icons.attach_money_rounded,
                                    hint: "0.00",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 2: Discount Price + Per Day Rent
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildInputField(
                                    label: "Discount Price (₹)",
                                    controller: _discountController,
                                    icon: Icons.attach_money_rounded,
                                    hint: "0.00",
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildInputField(
                                    label: "Per Day Rent (₹)",
                                    controller: _rentController,
                                    icon: Icons.attach_money_rounded,
                                    hint: "300",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 3: Fixed Deposit + Return Charge
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildInputField(
                                    label: "Fixed Deposit (₹)",
                                    controller: _depositController,
                                    icon: Icons.attach_money_rounded,
                                    isRequired: true,
                                    hint: "3000",
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildInputField(
                                    label: "Return Charge (₹)",
                                    controller: _returnChargeController,
                                    icon: Icons.attach_money_rounded,
                                    isRequired: true,
                                    hint: "50",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 4: Service Charges + Status
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildInputField(
                                    label: "Service Charges (₹)",
                                    controller: _serviceChargeController,
                                    icon: Icons.attach_money_rounded,
                                    isRequired: true,
                                    hint: "70",
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: _buildStatusDropdown()),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "All fields marked with * are required",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E1B4B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D1B69),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                            Icons.health_and_safety_outlined,
                                            size: 16,
                                            color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Update Equipment",
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
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
        ),
      ),
    );
  }

  Widget _buildEquipmentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          "Medical Equipment Name",
          isRequired: true,
          icon: Icons.health_and_safety_outlined,
        ),
        const SizedBox(height: 8),
        _isLoadingTablets
            ? Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedTabletName ?? "Loading...",
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            : DropdownButtonFormField<String>(
                value: _tablets.any((t) => t.id == _selectedTabletId)
                    ? _selectedTabletId
                    : (_tablets.isNotEmpty ? _tablets.first.id : null),
                isExpanded: true,
                decoration: _inputDecoration(hint: "Select Equipment"),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.black87),
                items: _tablets.map((tablet) {
                  return DropdownMenuItem<String>(
                    value: tablet.id,
                    child: Text(
                      tablet.name,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    final matched = _tablets.firstWhere(
                      (t) => t.id == val,
                      orElse: () => MedicalEquipmentDropdownItem(
                          id: val, name: _selectedTabletName ?? ''),
                    );
                    setState(() {
                      _selectedTabletId = val;
                      _selectedTabletName = matched.name;
                      _selectedCategory = matched.subcategory?.name;
                    });
                  }
                },
                validator: (val) => (val == null || val.isEmpty)
                    ? "Equipment name is required"
                    : null,
              ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          "Status",
          isRequired: true,
          icon: Icons.health_and_safety_outlined,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedStatus,
          isExpanded: true,
          decoration: _inputDecoration(hint: "Status"),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.black87),
          items: [
            DropdownMenuItem(
              value: 'active',
              child: Text(
                "Active",
                style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
              ),
            ),
            DropdownMenuItem(
              value: 'inactive',
              child: Text(
                "Inactive",
                style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
              ),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedStatus = val);
            }
          },
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isRequired = false,
    String hint = "0.00",
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: isRequired, icon: icon),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
          decoration: _inputDecoration(hint: hint),
          validator: isRequired
              ? (val) => (val == null || val.trim().isEmpty) ? "Required" : null
              : null,
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false, IconData? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: Colors.grey.shade600),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ),
        if (isRequired)
          Text(
            " *",
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF6B48FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
