import 'dart:async';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/medical_treatment/data/models/medical_treatment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/medical_treatment_bloc.dart';
import '../bloc/medical_treatment_event.dart';

class MedicalTreatmentVariantFormData {
  final String? id;
  final String variantId;
  final String name;
  final TextEditingController price;
  final TextEditingController discount;
  final TextEditingController quantity;
  bool isInStock;
  bool isActive;

  MedicalTreatmentVariantFormData({
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

class AddMedicalTreatmentSheet extends StatefulWidget {
  final MedicalTreatmentItem? editItem;
  final VoidCallback onSuccess;
  final List<String> existingIds;

  const AddMedicalTreatmentSheet({
    super.key,
    this.editItem,
    required this.onSuccess,
    this.existingIds = const [],
  });

  @override
  State<AddMedicalTreatmentSheet> createState() =>
      _AddMedicalTreatmentSheetState();
}

class _AddMedicalTreatmentSheetState extends State<AddMedicalTreatmentSheet> {
  final _formKey = GlobalKey<FormState>();

  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _searchController = TextEditingController();

  String _selectedStatus = 'active';
  String? _selectedTabletId;
  String? _selectedCategory;
  bool _isSubmitting = false;
  bool _isFetchingVariants = false;
  List<MedicalTreatmentVariantFormData> _variants = [];

  List<MedicalTreatmentDropdownItem> _searchResults = [];
  Timer? _debounce;

  bool get isEditMode => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final item = widget.editItem!;
      _priceController.text = item.price.toInt().toString();
      _discountController.text = item.discountPrice.toInt().toString();
      _selectedStatus = item.status;
      _selectedTabletId = item.details.id;
      _searchController.text = item.details.name;
      _selectedCategory = item.details.subcategory?.name;
      _loadEditData();
    }
  }

  void _loadEditData() {
    setState(() => _isFetchingVariants = true);
    context.read<MedicalTreatmentBloc>().add(
          FetchTreatmentFullDetailsEvent(
            widget.editItem!.id,
            onSuccess: (data) {
              if (!mounted) return;
              final tabletData = data['tablets'] ?? {};
              final List variantDetailsJson = data['variantdetails'] ?? [];
              final List tabletVariantsJson = tabletData['tabletvariant'] ??
                  tabletData['tabletvariants'] ??
                  [];

              setState(() {
                _priceController.text = (data['price'] ?? 0).toString();
                _discountController.text =
                    (data['discountprice'] ?? data['discount'] ?? 0).toString();
                _selectedStatus = data['status'] ?? 'active';

                if (variantDetailsJson.isNotEmpty) {
                  for (var v in _variants) {
                    v.dispose();
                  }
                  _variants = variantDetailsJson.map((vd) {
                    final tvMatch = tabletVariantsJson.firstWhere(
                      (tv) =>
                          tv['_id'] == vd['variantId'] ||
                          tv['_id'] == vd['varantId'],
                      orElse: () => null,
                    );
                    return MedicalTreatmentVariantFormData(
                      id: vd['_id'],
                      variantId: vd['variantId'] ?? vd['varantId'] ?? '',
                      name: tvMatch != null ? tvMatch['name'] : 'Unknown Variant',
                      defaultPrice: (vd['price'] ?? 0).toString(),
                      defaultDiscount:
                          (vd['discountprice'] ?? vd['discount'] ?? 0).toString(),
                      defaultStock: (vd['stock'] ?? 0).toString(),
                      defaultIsInStock: vd['isStock'] ?? true,
                      defaultIsActive: vd['status'] == 'active',
                    );
                  }).toList();
                }
                _isFetchingVariants = false;
              });
            },
            onError: (_) {
              if (mounted) setState(() => _isFetchingVariants = false);
            },
          ),
        );
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<MedicalTreatmentBloc>().add(
            SearchTreatmentDropdownTabletsEvent(
              query,
              onSuccess: (results) {
                if (mounted) setState(() => _searchResults = results);
              },
              onError: (_) {
                if (mounted) setState(() => _searchResults = []);
              },
            ),
          );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTabletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a treatment'),
          backgroundColor: Colors.red));
      return;
    }

    if (!isEditMode && widget.existingIds.contains(_selectedTabletId!)) {
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
        (firstVariant != null
            ? (double.tryParse(firstVariant.price.text) ?? 0)
            : 0);
    final double topDiscount = double.tryParse(_discountController.text) ??
        (firstVariant != null
            ? (double.tryParse(firstVariant.discount.text) ?? 0)
            : 0);

    setState(() => _isSubmitting = true);

    final payload = {
      'name': isEditMode ? widget.editItem!.id : _selectedTabletId,
      'category': _selectedCategory ?? 'General',
      'price': topPrice,
      'discount': topDiscount,
      'discountprice': topDiscount,
      'status': _selectedStatus,
      'type': 'general',
      'description': '',
      'duration': '',
      'procedureType': '',
      'complexityLevel': '',
      'recoveryTime': '',
      'requirements': [],
      'sideEffects': [],
      if (_variants.isNotEmpty)
        'variants': _variants.map((v) => {
              if (v.id != null) '_id': v.id,
              'variantId': v.variantId,
              'varantId': v.variantId,
              'name': v.name,
              'price': double.tryParse(v.price.text) ?? 0,
              'discount': double.tryParse(v.discount.text) ?? 0,
              'discountprice': double.tryParse(v.discount.text) ??
                  double.tryParse(v.price.text) ??
                  0,
              'discountType': 'price',
              'stock': int.tryParse(v.quantity.text) ?? 0,
              'isStock': v.isInStock,
              'status': v.isActive ? 'active' : 'inactive',
            }).toList(),
    };

    if (isEditMode) {
      context.read<MedicalTreatmentBloc>().add(
            UpdateMedicalTreatmentEvent(
              widget.editItem!.id,
              payload,
              onSuccess: () {
                widget.onSuccess();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              onError: (msg) {
                if (mounted) {
                  setState(() => _isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          );
    } else {
      context.read<MedicalTreatmentBloc>().add(
            CreateMedicalTreatmentEvent(
              payload,
              onSuccess: () {
                widget.onSuccess();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              onError: (msg) {
                if (mounted) {
                  setState(() => _isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.medical_information_outlined,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditMode
                            ? 'Edit Medical Treatment'
                            : 'Add New Medical Treatment',
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1B4B)),
                      ),
                      Text(
                        'Fill in the details to ${isEditMode ? 'update' : 'add'} a medical treatment',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF1E1B4B))),
              ],
            ),
          ),
          const Divider(height: 24),
          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Treatment Information",
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1B4B))),
                    Text("Search and pick from global medical treatments",
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 20),

                    // Search Name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Treatment Name",
                            isRequired: !isEditMode,
                            icon: isEditMode
                                ? Icons.medical_information_outlined
                                : Icons.search),
                        const SizedBox(height: 8),
                        _buildSearchField(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Dynamic Variants or Fallback Price/Discount
                    if (_isFetchingVariants) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ] else if (_variants.isNotEmpty) ...[
                      Text(
                        "Treatment Variants",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E1B4B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._variants.asMap().entries.map(
                            (e) => _buildVariantSection(e.value, e.key),
                          ),
                    ] else ...[
                      // Single Price & Discount fields if no variants
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Price (₹)",
                                    isRequired: true,
                                    icon: Icons.currency_rupee),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.inter(fontSize: 13),
                                  decoration: _inputDecoration(hint: "0.00"),
                                  validator: (val) =>
                                      (val == null || val.isEmpty)
                                          ? "Required"
                                          : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Discount Price (₹)",
                                    isRequired: true,
                                    icon: Icons.local_offer_outlined),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _discountController,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.inter(fontSize: 13),
                                  decoration: _inputDecoration(hint: "0.00"),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "Required";
                                    }
                                    final discount = double.tryParse(val);
                                    final price =
                                        double.tryParse(_priceController.text);
                                    if (discount != null &&
                                        price != null &&
                                        discount > price) {
                                      return "Over price";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (isEditMode) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Status",
                                    isRequired: true,
                                    icon: Icons.check_circle_outline),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedStatus,
                                  isExpanded: true,
                                  decoration:
                                      _inputDecoration(hint: "Select Status"),
                                  style: GoogleFonts.inter(
                                      fontSize: 13, color: Colors.black87),
                                  items: [
                                    DropdownMenuItem(
                                        value: 'active',
                                        child: Text("Active",
                                            style: GoogleFonts.inter(
                                                fontSize: 13))),
                                    DropdownMenuItem(
                                        value: 'inactive',
                                        child: Text("Inactive",
                                            style: GoogleFonts.inter(
                                                fontSize: 13))),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => _selectedStatus = val!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!))),
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
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add, size: 16),
                    label: Text(
                        isEditMode ? "Update Treatment" : "Add Treatment",
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantSection(
      MedicalTreatmentVariantFormData v, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Variant ${index + 1}",
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          _buildStaticField("Variant Name", v.name, Icons.link_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Price (₹)",
                  v.price,
                  hint: "0.00",
                  icon: Icons.currency_rupee,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  "Discount Price (₹)",
                  v.discount,
                  hint: "0.00",
                  icon: Icons.local_offer_outlined,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF1E1B4B),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    required String hint,
    required IconData icon,
    bool isRequired = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: isRequired, icon: icon),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(fontSize: 13),
          decoration: _inputDecoration(hint: hint),
          validator: validator ??
              (val) => (isRequired && (val == null || val.isEmpty))
                  ? "Required"
                  : null,
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Column(
      children: [
        TextFormField(
          controller: _searchController,
          enabled: !isEditMode,
          style: GoogleFonts.inter(
              fontSize: 13,
              color: isEditMode ? Colors.grey[600] : Colors.black87),
          onTap: () {
            if (!isEditMode && _searchResults.isEmpty) {
              _onSearchChanged(_searchController.text);
            }
          },
          decoration: _inputDecoration(hint: "Select Treatment...").copyWith(
            suffixIcon: isEditMode
                ? null
                : InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (_searchResults.isEmpty) {
                        _onSearchChanged(_searchController.text);
                      } else {
                        setState(() => _searchResults = []);
                      }
                    },
                    child: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ),
            fillColor: isEditMode ? Colors.grey[50] : Colors.white,
          ),
          onChanged: (q) {
            setState(() {
              _selectedTabletId = null;
              for (var v in _variants) {
                v.dispose();
              }
              _variants = [];
            });
            _onSearchChanged(q);
          },
          validator: (_) => _selectedTabletId == null ? "Required" : null,
        ),
        if (!isEditMode &&
            _searchResults.isNotEmpty &&
            _selectedTabletId == null)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                )
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (_, i) {
                final item = _searchResults[i];
                return InkWell(
                  onTap: () {
                    final selectedId = item.id;
                    setState(() {
                      _selectedTabletId = selectedId;
                      _searchController.text = item.name;
                      _selectedCategory = item.subcategory?.name;
                      _searchResults = [];
                      _isFetchingVariants = true;
                    });

                    context.read<MedicalTreatmentBloc>().add(
                          FetchTreatmentTabletDetailsEvent(
                            selectedId,
                            onSuccess: (tabletData) {
                              if (!mounted) return;
                              final List rawVariants =
                                  tabletData['tabletvariants'] as List? ??
                                      tabletData['tabletvariant'] as List? ??
                                      tabletData['variants'] as List? ??
                                      tabletData['variant'] as List? ??
                                      [];
                              setState(() {
                                for (var v in _variants) {
                                  v.dispose();
                                }
                                _variants = rawVariants.map((tv) {
                                  return MedicalTreatmentVariantFormData(
                                    variantId: (tv['_id'] ?? tv['variantId'] ?? tv['varantId'] ?? '').toString(),
                                    name: (tv['name'] ?? 'Unknown Variant').toString(),
                                    defaultPrice:
                                        (tv['price'] ?? 0).toString(),
                                    defaultDiscount:
                                        (tv['discountprice'] ?? tv['discount'] ?? '').toString(),
                                    defaultStock:
                                        (tv['stock'] ?? 0).toString(),
                                    defaultIsInStock: tv['isStock'] ?? true,
                                    defaultIsActive: tv['status'] == 'active' || tv['status'] == null,
                                  );
                                }).toList();
                                if (rawVariants.isEmpty && tabletData['price'] != null) {
                                  _priceController.text = (tabletData['price'] ?? 0).toString();
                                }
                                _isFetchingVariants = false;
                              });
                            },
                            onError: (_) {
                              if (mounted) {
                                setState(() => _isFetchingVariants = false);
                              }
                            },
                          ),
                        );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Text(item.name,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: const Color(0xFF1E1B4B))),
                  ),
                );
              },
            ),
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
    );
  }
}
