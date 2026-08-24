import 'dart:async';
import 'package:MediCompare/features/medicine/data/data_sources/medicine_service.dart';
import 'package:MediCompare/features/medicine/data/models/medicine_model.dart';
import 'package:MediCompare/features/medicine/medicine_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicineVariantFormData {
  final String? id;
  final String variantId;
  final String name;
  final TextEditingController price;
  final TextEditingController discount;
  final TextEditingController quantity;
  final TextEditingController perUnit;
  final TextEditingController perUnitPercent;
  String discountType;
  bool isInStock;
  bool isActive;

  MedicineVariantFormData({
    this.id,
    required this.variantId,
    required this.name,
    required String defaultPrice,
    String defaultPerUnit = '',
    String defaultDiscount = '',
    String defaultStock = '0',
    String defaultDiscountType = 'price',
    bool defaultIsInStock = true,
    bool defaultIsActive = true,
  })  : price = TextEditingController(text: defaultPrice),
        discount = TextEditingController(text: defaultDiscount),
        quantity = TextEditingController(text: defaultStock),
        perUnit = TextEditingController(text: defaultPerUnit),
        perUnitPercent = TextEditingController(),
        discountType = defaultDiscountType,
        isInStock = defaultIsInStock,
        isActive = defaultIsActive;

  void dispose() {
    price.dispose();
    discount.dispose();
    quantity.dispose();
    perUnit.dispose();
    perUnitPercent.dispose();
  }
}

class AddMedicineSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final MedicineItem? editMedicine;
  final List<String> existingIds;

  const AddMedicineSheet({
    super.key,
    required this.onSuccess,
    this.editMedicine,
    this.existingIds = const [],
  });

  @override
  State<AddMedicineSheet> createState() => _AddMedicineSheetState();
}

class _AddMedicineSheetState extends State<AddMedicineSheet> {
  final _formKey = GlobalKey<FormState>();
  final MedicineService _medicineService =
      MedicineInjection.provideMedicineService();

  MedicineDropdownItem? _selectedTablet;

  final _mrpPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _pricePerUnitController = TextEditingController();
  final _percentagePerUnitController = TextEditingController();

  String? _selectedReturnPolicy;
  String _discountType = 'price';
  bool _isInStock = true;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isFetchingDetails = false;
  List<MedicineVariantFormData> _variants = [];

  final _searchController = TextEditingController();
  List<MedicineDropdownItem> _searchResults = [];
  Timer? _debounce;

  bool get isEditMode => widget.editMedicine != null;

  final List<Map<String, dynamic>> _returnPolicies = [
    {'label': '3 Days', 'value': 3},
    {'label': '7 Days', 'value': 7},
    {'label': '14 Days', 'value': 14},
    {'label': '21 Days', 'value': 21},
    {'label': 'Non returnable', 'value': 0},
  ];

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
      final data = await _medicineService
          .getVendorMedicineDetails(widget.editMedicine!.id);

      final tabletData = data['tablets'] ?? {};
      final tabletId = tabletData['_id'] ?? data['name'];

      setState(() {
        _selectedTablet = MedicineDropdownItem(
          id: tabletId,
          name: tabletData['name'] ?? '',
          price: (tabletData['price'] ?? 0).toDouble(),
          subcategoryId: data['subcategoryId'] ?? '',
        );
        _searchController.text = _selectedTablet!.name;

        _selectedReturnPolicy = data['returnDetails']?.toString();
        _discountType = data['discountType']?.toString() ?? 'price';
        _mrpPriceController.text = (data['price'] ?? 0).toString();
        _discountController.text =
            (data['discountprice'] ?? data['discount'] ?? 0).toString();
        _quantityController.text = (data['quantity'] ?? 1).toString();
        _pricePerUnitController.text = (data['pricePerUnit'] ?? '').toString();
        _percentagePerUnitController.text =
            (data['percentagePerUnit'] ?? '').toString();

        _isInStock = data['isStock'] ?? true;
        _isActive = data['status'] == 'active';

        // Load variants
        final List variantDetailsJson = data['variantdetails'] ?? [];
        // final tabletVariantsJson = tabletData['tabletvariant'] ??
        tabletData['tabletvariants'] ?? [];

        _variants = variantDetailsJson.map((vd) {
          final tvMatch = (tabletData['tabletvariant'] as List?)?.firstWhere(
              (tv) =>
                  tv['_id'] == vd['variantId'] || tv['_id'] == vd['varantId'],
              orElse: () => null);
          return MedicineVariantFormData(
            id: vd['_id'],
            variantId: vd['variantId'] ?? vd['varantId'],
            name: tvMatch != null ? tvMatch['name'] : 'Unknown Variant',
            defaultPrice: (vd['price'] ?? 0).toString(),
            defaultDiscount: (vd['discountprice'] ?? 0).toString(),
            defaultStock: (vd['stock'] ?? 0).toString(),
            defaultPerUnit: (vd['pricePerUnit'] ?? '').toString(),
            defaultDiscountType: vd['discountType'] ?? 'price',
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
    _mrpPriceController.dispose();
    _discountController.dispose();
    _quantityController.dispose();
    _pricePerUnitController.dispose();
    _percentagePerUnitController.dispose();
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
        final results = await _medicineService.searchMedicineDropdown(query);
        if (mounted) setState(() => _searchResults = results.take(20).toList());
      } catch (_) {}
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTablet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a medicine first')));
      return;
    }

    if (!isEditMode && widget.existingIds.contains(_selectedTablet!.id)) {
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
    final double? topLevelPrice = double.tryParse(_mrpPriceController.text);
    final double topPrice = (topLevelPrice != null && topLevelPrice > 0)
        ? topLevelPrice
        : (firstVariant != null
            ? (double.tryParse(firstVariant.price.text) ?? 0)
            : 0);

    final double? topLevelDiscount = double.tryParse(_discountController.text);
    final double topDiscount =
        (topLevelDiscount != null && topLevelDiscount > 0)
            ? topLevelDiscount
            : (firstVariant != null
                ? (double.tryParse(firstVariant.discount.text) ?? 0)
                : 0);

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> payload = {
        "name": isEditMode ? widget.editMedicine!.id : _selectedTablet!.id,
        "price": topPrice,
        "discountprice": topDiscount,
        "discount": topDiscount,
        "discountType": _discountType,
        "returnDetails": int.tryParse(_selectedReturnPolicy ?? '0') ?? 0,
        "variants": _variants
            .map((v) => {
                  if (v.id != null) "_id": v.id,
                  "variantId": v.variantId,
                  "varantId": v
                      .variantId, // Support internal typo in backend for updates
                  "name": v.name,
                  "price": double.tryParse(v.price.text) ?? 0,
                  "discount": double.tryParse(v.discount.text) ?? 0,
                  "discountprice": double.tryParse(v.discount.text) ?? 0,
                  "discountType": v.discountType,
                  "stock": int.tryParse(v.quantity.text) ?? 0,
                  "quantity": int.tryParse(v.quantity.text) ?? 0,
                  "isStock": v.isInStock,
                  "status": v.isActive ? "active" : "inactive",
                  "pricePerUnit": v.perUnit.text,
                  "removeImage": false,
                })
            .toList(),
        "quantity": int.tryParse(_quantityController.text) ?? 0,
        "pricePerUnit": double.tryParse(_pricePerUnitController.text) ?? 0,
        "isStock": _isInStock,
        "status": _isActive ? "active" : "inactive",
        "files": []
      };

      if (isEditMode) {
        payload["removeFrontImage"] = false;
        payload["frontImage"] = null;
        payload["stock"] = payload["quantity"];
        payload["removeImage"] = false;
        await _medicineService.updateMedicine(widget.editMedicine!.id, payload);
      } else {
        payload["facilities"] = [];
        await _medicineService.addMedicine(payload);
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
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingDetails) {
      return Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

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
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(12)),
                    child:
                        const Icon(Icons.link, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEditMode ? "Edit Medicine" : "Add New Medicine",
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E1B4B))),
                        Text(
                            isEditMode
                                ? "Update the medicine information"
                                : "Fill in the basic Medicine information",
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
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
                      Text("Medicine Information",
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E1B4B))),
                      const SizedBox(height: 4),
                      Text(
                          isEditMode
                              ? "Update the medicine details below"
                              : "Please provide accurate information for the medicine",
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 24),

                      // Medicine Name Input
                      _buildLabel("Medicine Name",
                          isRequired: true, icon: Icons.link),
                      const SizedBox(height: 8),
                      if (isEditMode && _selectedTablet != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(_selectedTablet!.name,
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
                        Text(
                            "10 medicines in database. Medicine name cannot be changed.",
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey[500])),
                      ] else ...[
                        Column(
                          children: [
                            TextFormField(
                              controller: _searchController,
                              style: GoogleFonts.poppins(fontSize: 14),
                              onTap: () {
                                if (_searchController.text.isEmpty) {
                                  _onSearchChanged('');
                                }
                              },
                              decoration: _inputDecoration(
                                      hint: "e.g., Paracetamol, Ibuprofen...")
                                  .copyWith(
                                      suffixIcon: const Icon(
                                          Icons.keyboard_arrow_down)),
                              onChanged: (val) {
                                setState(() {
                                  _selectedTablet = null;
                                });
                                _onSearchChanged(val);
                              },
                              validator: (value) =>
                                  _selectedTablet == null ? "Required" : null,
                            ),
                            if (_selectedTablet == null &&
                                _searchResults.isNotEmpty)
                              Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 200),
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
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
                                        setState(
                                            () => _isFetchingDetails = true);
                                        try {
                                          final fullDetails =
                                              await _medicineService
                                                  .getMedicineDetails(
                                                      option.id);
                                          setState(() {
                                            _selectedTablet = fullDetails;
                                            _searchController.text =
                                                fullDetails.name;
                                            _mrpPriceController.text =
                                                fullDetails.price.toString();
                                            _searchResults = [];

                                            // Populate variants from selection
                                            for (var v in _variants) {
                                              v.dispose();
                                            }
                                            _variants = fullDetails
                                                .tabletVariants
                                                .map((tv) =>
                                                    MedicineVariantFormData(
                                                      variantId: tv.id,
                                                      name: tv.name,
                                                      defaultPrice:
                                                          tv.price.toString(),
                                                      defaultPerUnit:
                                                          tv.pricePerUnit ?? '',
                                                      defaultStock: tv.stock
                                                              ?.toString() ??
                                                          '0',
                                                    ))
                                                .toList();
                                          });
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Error fetching details: $e')));
                                          }
                                        } finally {
                                          if (mounted)
                                            setState(() =>
                                                _isFetchingDetails = false);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
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

                      const SizedBox(height: 20),
                      _buildLabel("Return Policy", isRequired: true),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _selectedReturnPolicy != null
                            ? int.tryParse(_selectedReturnPolicy!)
                            : null,
                        decoration:
                            _inputDecoration(hint: "Select Return Policy"),
                        items: _returnPolicies
                            .map((p) => DropdownMenuItem<int>(
                                  value: p['value'] as int,
                                  child: Text(p['label'] as String,
                                      style: GoogleFonts.poppins(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (val) => setState(
                            () => _selectedReturnPolicy = val?.toString()),
                        validator: (val) => val == null ? "Required" : null,
                      ),

                      if (_selectedTablet != null) ...[
                        const SizedBox(height: 32),
                        if (_variants.isEmpty) ...[
                          Text("Medicine Details",
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E1B4B))),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildStaticField(
                                            "Medicine Name",
                                            _selectedTablet!.name,
                                            Icons.link)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: _buildTextField(
                                            "Price (₹)", _mrpPriceController,
                                            hint: "0.00",
                                            icon: Icons.currency_rupee)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildLabel("Discount Type",
                                    icon: Icons.percent),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDiscountTypeBtn(
                                        "₹ Price",
                                        'price',
                                        _discountType,
                                        (val) =>
                                            setState(() => _discountType = val),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildDiscountTypeBtn(
                                        "% Percentage",
                                        'percentage',
                                        _discountType,
                                        (val) =>
                                            setState(() => _discountType = val),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                    _discountType == 'price'
                                        ? "Discount Price (₹)"
                                        : "Discount Percentage (%)",
                                    _discountController,
                                    hint: _discountType == 'price'
                                        ? "e.g., 50"
                                        : "e.g., 10",
                                    icon: _discountType == 'price'
                                        ? Icons.currency_rupee
                                        : Icons.percent, validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return "Required";
                                  }
                                  final discount = double.tryParse(val);
                                  final mrp =
                                      double.tryParse(_mrpPriceController.text);
                                  if (discount != null && mrp != null) {
                                    if (_discountType == 'price' &&
                                        discount > mrp) {
                                      return "Over MRP";
                                    } else if (_discountType == 'percentage' &&
                                        discount > 100) {
                                      return "Invalid %";
                                    }
                                  }
                                  return null;
                                }),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildTextField(
                                            "Quantity", _quantityController,
                                            hint: "0",
                                            icon: Icons.inventory_2_outlined)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: _buildTextField("Price/Units",
                                            _pricePerUnitController,
                                            hint: "e.g., ₹10/tab",
                                            icon: Icons.currency_rupee,
                                            isRequired: false)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildTextField(
                                            "Percentage/Unit",
                                            _percentagePerUnitController,
                                            hint: "e.g., 10%",
                                            icon: Icons.percent,
                                            isRequired: false)),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel("Stock Status",
                                              isRequired: false),
                                          const SizedBox(height: 8),
                                          _buildToggleBtn(
                                            _isInStock
                                                ? "In Stock"
                                                : "Out of Stock",
                                            _isInStock
                                                ? Icons.check_circle_outline
                                                : Icons.cancel_outlined,
                                            _isInStock
                                                ? Colors.green
                                                : Colors.red,
                                            () => setState(
                                                () => _isInStock = !_isInStock),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    if (isEditMode)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildLabel("Active Status",
                                                isRequired: false),
                                            const SizedBox(height: 8),
                                            _buildToggleBtn(
                                              _isActive ? "Active" : "Inactive",
                                              Icons.power_settings_new,
                                              _isActive
                                                  ? const Color(0xFF506CCF)
                                                  : Colors.grey,
                                              () => setState(
                                                  () => _isActive = !_isActive),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Text("Variants",
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

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel",
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color(0xFF1E1B4B),
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          onPressed: _isLoading ? null : _submit,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.link, size: 16),
                          label: Text(
                              _isLoading
                                  ? "Saving..."
                                  : (isEditMode
                                      ? "Update Medicine"
                                      : "Add Medicine"),
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false, IconData? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4B5563)),
          ),
        ),
        if (isRequired)
          Text(" *",
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF7C3AED))),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red)),
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
              (val) {
                if (isRequired && (val == null || val.isEmpty)) {
                  return "Required";
                }
                return null;
              },
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

  Widget _buildVariantSection(MedicineVariantFormData v, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Expanded(
                  child: _buildStaticField("Variant Name", v.name, Icons.link)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTextField("Price (₹)", v.price,
                      hint: "0.00", icon: Icons.currency_rupee)),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabel("Discount Type", icon: Icons.percent),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDiscountTypeBtn(
                  "₹ Price",
                  'price',
                  v.discountType,
                  (val) => setState(() => v.discountType = val),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDiscountTypeBtn(
                  "% Percentage",
                  'percentage',
                  v.discountType,
                  (val) => setState(() => v.discountType = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
              v.discountType == 'price'
                  ? "Discount Price (₹)"
                  : "Discount Percentage (%)",
              v.discount,
              hint: v.discountType == 'price' ? "e.g., 50" : "e.g., 10",
              icon: v.discountType == 'price'
                  ? Icons.currency_rupee
                  : Icons.percent, validator: (val) {
            if (val == null || val.isEmpty) {
              return null; // Allowed to be empty maybe? Or from screenshot it has a label
            }
            final discount = double.tryParse(val);
            final mrp = double.tryParse(v.price.text);
            if (discount != null && mrp != null) {
              if (v.discountType == 'price' && discount > mrp) {
                return "Over MRP";
              } else if (v.discountType == 'percentage' && discount > 100) {
                return "Invalid %";
              }
            }
            return null;
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildTextField("Quantity", v.quantity,
                      hint: "0", icon: Icons.inventory_2_outlined)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTextField("Price/Units", v.perUnit,
                      hint: "e.g., ₹10/tab",
                      icon: Icons.currency_rupee,
                      isRequired: false)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildTextField("Percentage/Unit", v.perUnitPercent,
                      hint: "e.g., 10%",
                      icon: Icons.percent,
                      isRequired: false)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Stock Status", isRequired: false),
                    const SizedBox(height: 8),
                    _buildToggleBtn(
                      v.isInStock ? "In Stock" : "Out of Stock",
                      v.isInStock
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      v.isInStock ? Colors.green : Colors.red,
                      () => setState(() => v.isInStock = !v.isInStock),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isEditMode)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Active Status", isRequired: false),
                      const SizedBox(height: 8),
                      _buildToggleBtn(
                        v.isActive ? "Active" : "Inactive",
                        Icons.power_settings_new,
                        v.isActive ? const Color(0xFF506CCF) : Colors.grey,
                        () => setState(() => v.isActive = !v.isActive),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountTypeBtn(String label, String type, String currentType,
      Function(String) onSelect) {
    final isSelected = currentType == type;
    return GestureDetector(
      onTap: () => onSelect(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF7C3AED) : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
