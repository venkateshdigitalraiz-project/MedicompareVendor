import 'dart:async';
import 'package:MediCompare/features/surgery/data/data_sources/surgery_service.dart';
import 'package:MediCompare/features/surgery/data/models/surgery_model.dart';
import 'package:MediCompare/features/surgery/surgery_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SurgeryVariantFormData {
  final String? id;
  final String variantId;
  final String name;
  final TextEditingController price;
  final TextEditingController discount;
  final TextEditingController quantity;
  bool isInStock;
  bool isActive;

  SurgeryVariantFormData({
    this.id,
    required this.variantId,
    required this.name,
    required String defaultPrice,
    String defaultDiscount = '',
    String defaultStock = '0',
    bool defaultIsInStock = true,
    bool defaultIsActive = true,
  })  : price = TextEditingController(text: defaultPrice),
        discount = TextEditingController(text: defaultDiscount),
        quantity = TextEditingController(text: defaultStock),
        isInStock = defaultIsInStock,
        isActive = defaultIsActive;

  void dispose() {
    price.dispose();
    discount.dispose();
    quantity.dispose();
  }
}

class AddSurgerySheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final SurgeryItem? editSurgery;
  final List<String> existingIds;

  const AddSurgerySheet({
    super.key,
    required this.onSuccess,
    this.editSurgery,
    this.existingIds = const [],
  });

  @override
  State<AddSurgerySheet> createState() => _AddSurgerySheetState();
}

class _AddSurgerySheetState extends State<AddSurgerySheet> {
  final _formKey = GlobalKey<FormState>();
  final SurgeryService _surgeryService =
      SurgeryInjection.provideSurgeryService();

  SurgeryDropdownItem? _selectedSurgery;
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  bool _isFetchingDetails = false;
  List<SurgeryVariantFormData> _variants = [];

  final _searchController = TextEditingController();
  List<SurgeryDropdownItem> _searchResults = [];
  Timer? _debounce;

  bool get isEditMode => widget.editSurgery != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _loadEditData();
    }
  }

  Future<void> _loadEditData() async {
    setState(() => _isFetchingDetails = true);
    try {
      final data = await _surgeryService
          .getSurgeryFullDetails(widget.editSurgery!.id);

      final tabletData = data['tablets'] ?? {};
      final tabletId = tabletData['_id'] ?? data['name'];

      setState(() {
        _selectedSurgery = SurgeryDropdownItem(
          id: tabletId,
          name: tabletData['name'] ?? '',
          subcategoryId: data['subcategoryId'] ?? '',
          complexity: tabletData['complexity'],
          duration: tabletData['duration'],
          description: tabletData['description'],
        );
        _searchController.text = _selectedSurgery?.name ?? '';
        _priceController.text = (data['price'] ?? 0).toString();
        _discountController.text =
            (data['discountprice'] ?? data['discount'] ?? 0).toString();
        _isActive = data['status'] == 'active';

        // Load variants
        final List variantDetailsJson = data['variantdetails'] ?? [];
        final List tabletVariantsJson = tabletData['tabletvariant'] ?? [];

        _variants = variantDetailsJson.map((vd) {
          final tvMatch = tabletVariantsJson.firstWhere(
            (tv) => tv['_id'] == vd['variantId'] || tv['_id'] == vd['varantId'],
            orElse: () => null,
          );
          return SurgeryVariantFormData(
            id: vd['_id'],
            variantId: vd['variantId'] ?? vd['varantId'],
            name: tvMatch != null ? tvMatch['name'] : 'Unknown Variant',
            defaultPrice: (vd['price'] ?? 0).toString(),
            defaultDiscount:
                (vd['discountprice'] ?? vd['discount'] ?? 0).toString(),
            defaultStock: (vd['stock'] ?? 0).toString(),
            defaultIsInStock: vd['isStock'] ?? true,
            defaultIsActive: vd['status'] == 'active',
          );
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isFetchingDetails = false);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    _searchController.dispose();
    for (var v in _variants) {
      v.dispose();
    }
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _surgeryService.getCommonSurgeries(query);
        if (mounted) setState(() => _searchResults = results);
      } catch (_) {}
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSurgery == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a surgery first')));
      return;
    }

    if (!isEditMode && widget.existingIds.contains(_selectedSurgery!.id)) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('This product already present'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final firstVariant = _variants.isNotEmpty ? _variants.first : null;
    final double topPrice = double.tryParse(_priceController.text) ?? 
        (firstVariant != null ? (double.tryParse(firstVariant.price.text) ?? 0) : 0);
    final double topDiscount = double.tryParse(_discountController.text) ??
        (firstVariant != null ? (double.tryParse(firstVariant.discount.text) ?? 0) : 0);

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> payload = {
        "name": isEditMode ? widget.editSurgery!.id : _selectedSurgery!.id,
        "category": _selectedSurgery!.subcategoryId,
        "price": topPrice,
        "discountprice": topDiscount,
        "discount": topDiscount,
        "status": _isActive ? "active" : "inactive",
        "type": "general",
        "complexity": _selectedSurgery!.complexity ?? "simple",
        "duration": _selectedSurgery!.duration ?? "",
        "description": _selectedSurgery!.description ?? "",
        "variants": _variants.map((v) => {
          if (v.id != null) "_id": v.id,
          "variantId": v.variantId,
          "varantId": v.variantId,
          "name": v.name,
          "price": double.tryParse(v.price.text) ?? 0,
          "discount": double.tryParse(v.discount.text) ?? 0,
          "discountprice": double.tryParse(v.discount.text) ?? double.tryParse(v.price.text) ?? 0,
          "discountType": "price",
          "stock": int.tryParse(v.quantity.text) ?? 0,
          "isStock": v.isInStock,
          "status": v.isActive ? "active" : "inactive",
        }).toList(),
      };

      if (isEditMode) {
        // According to user's example, update payload uses product ID in 'name' field
        payload["name"] = widget.editSurgery!.id;
        await _surgeryService.updateSurgery(widget.editSurgery!.id, payload);
      } else {
        await _surgeryService.createSurgery(payload);
      }

      widget.onSuccess();
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? 'Updated successfully'
                : 'Product added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildVariantSection(SurgeryVariantFormData v, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Variant ${index + 1}",
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800])),
          const SizedBox(height: 16),
          _buildStaticField("Variant Name", v.name, Icons.link_outlined),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Price (₹)",
                  v.price,
                  hint: "0.00",
                  icon: Icons.show_chart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  "Discount Price (₹)",
                  v.discount,
                  hint: "0.00",
                  icon: Icons.show_chart,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Required";
                    final discount = double.tryParse(val);
                    final price = double.tryParse(v.price.text) ?? 0;
                    if (discount != null && discount > price) {
                      return "> price (₹${price.toStringAsFixed(0)})";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaticField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: true, icon: icon),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: const Color(0xFF1E1B4B)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {required String hint,
      required IconData icon,
      bool isRequired = true,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: isRequired, icon: icon),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(hint: hint),
          validator: validator ??
              (val) => (isRequired && (val == null || val.isEmpty))
                  ? "Required"
                  : null,
        ),
      ],
    );
  }

  Widget _buildToggleBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w500, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.show_chart,
                        color: Color(0xFF7C3AED), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEditMode ? "Edit Surgery" : "Add New Surgery",
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E1B4B))),
                        Text(
                            "Fill in the details to add a surgery to your system",
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: _isFetchingDetails
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Surgery Information",
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E1B4B))),
                      const SizedBox(height: 4),
                      Text(
                          isEditMode
                              ? "Update the surgery details below"
                              : "Please provide accurate information for the surgery",
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 24),
                      // Surgery Name Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Surgery Name",
                              isRequired: true, icon: Icons.link_outlined),
                          const SizedBox(height: 8),
                          if (isEditMode && _selectedSurgery != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(_selectedSurgery!.name,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: const Color(0xFF4B5563)),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text("Surgery name cannot be changed.",
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: Colors.grey[500])),
                          ] else ...[
                            Column(
                              children: [
                                TextFormField(
                                  controller: _searchController,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                  onTap: () {
                                    if (_searchController.text.isEmpty)
                                      _onSearchChanged('');
                                  },
                                  decoration:
                                      _inputDecoration(hint: "Search Surgery...")
                                          .copyWith(
                                              suffixIcon: const Icon(
                                                  Icons.keyboard_arrow_down)),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedSurgery = null;
                                    });
                                    _onSearchChanged(val);
                                  },
                                  validator: (value) => _selectedSurgery == null
                                      ? "Required"
                                      : null,
                                ),
                                if (_selectedSurgery == null &&
                                    _searchResults.isNotEmpty)
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxHeight: 250),
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.grey[200]!),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.05),
                                            blurRadius: 8)
                                      ],
                                    ),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: _searchResults.length,
                                      itemBuilder: (context, index) {
                                        final option = _searchResults[index];
                                        return InkWell(
                                          onTap: () async {
                                            setState(() {
                                              _selectedSurgery = option;
                                              _searchController.text =
                                                  option.name;
                                              _searchResults = [];

                                              // Auto-populate variants from common product
                                              _isFetchingDetails = true;
                                            });

                                            try {
                                              final details = await _surgeryService
                                                  .getCommonSurgeryDetails(
                                                      option.id);
                                              if (mounted) {
                                                setState(() {
                                                  for (var v in _variants)
                                                    v.dispose();
                                                  _variants = details
                                                      .tabletVariants
                                                      .map((tv) =>
                                                          SurgeryVariantFormData(
                                                            variantId: tv.id,
                                                            name: tv.name,
                                                            defaultPrice: tv
                                                                .price
                                                                .toString(),
                                                          ))
                                                      .toList();
                                                  _isFetchingDetails = false;
                                                });
                                              }
                                            } catch (_) {
                                              if (mounted)
                                                setState(() =>
                                                    _isFetchingDetails = false);
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            child: Text(option.name,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14)),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      if (_selectedSurgery != null) ...[
                        if (isEditMode) ...[
                          const SizedBox(height: 24),
                          Text("Status",
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E1B4B))),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildToggleBtn(
                                "Active",
                                Icons.check_circle_outline,
                                _isActive ? Colors.green : Colors.grey,
                                () => setState(() => _isActive = true),
                              ),
                              const SizedBox(width: 12),
                              _buildToggleBtn(
                                "Inactive",
                                Icons.remove_circle_outline,
                                !_isActive ? Colors.red : Colors.grey,
                                () => setState(() => _isActive = false),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 32),
                        if (_variants.isEmpty) ...[
                          Text("Surgery Price",
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E1B4B))),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Price (₹)",
                                    isRequired: true, icon: Icons.show_chart),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration(hint: "0.00"),
                                  validator: (val) => (val == null || val.isEmpty)
                                      ? "Required"
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                _buildLabel("Discount Price (₹)",
                                    isRequired: true, icon: Icons.show_chart),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _discountController,
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      _inputDecoration(hint: "0.00").copyWith(
                                    suffixIcon: const Icon(Icons.unfold_more,
                                        size: 18, color: Colors.grey),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty)
                                      return "Required";
                                    final discount = double.tryParse(val);
                                    final price =
                                        double.tryParse(_priceController.text) ?? 0;
                                    if (discount != null && discount > price) {
                                      return "> price (₹${price.toStringAsFixed(0)})";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Text("Surgery Variants",
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E1B4B))),
                          const SizedBox(height: 16),
                          ..._variants
                              .asMap()
                              .entries
                              .map((e) => _buildVariantSection(e.value, e.key))
                              .toList(),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),
            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel",
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF1E1B4B),
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.show_chart, size: 18),
                    label: Text(
                        _isLoading
                            ? "Saving..."
                            : (isEditMode ? "Update Surgery" : "Add Surgery"),
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {required bool isRequired, IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: Colors.grey[500]),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4B5563)),
          ),
        ),
        if (isRequired)
          Text(" *",
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED))),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red)),
    );
  }
}
