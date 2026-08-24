import '../bloc/ambulance_bloc.dart';
import '../bloc/ambulance_event.dart';
import '../bloc/ambulance_state.dart';
import '../../domain/entities/ambulance_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAmbulanceSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final AmbulanceEntity? editAmbulance;
  final List<String> existingIds;

  const AddAmbulanceSheet({
    super.key,
    required this.onSuccess,
    this.editAmbulance,
    this.existingIds = const [],
  });

  @override
  State<AddAmbulanceSheet> createState() => _AddAmbulanceSheetState();
}

class _AddAmbulanceSheetState extends State<AddAmbulanceSheet> {
  final _formKey = GlobalKey<FormState>();

  AmbulanceNameOptionEntity? _selectedAmbulance;
  List<String> _selectedFacilities = [];
  List<AmbulanceFacilityEntity> _availableFacilities = []; // cached locally

  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();

  String _status = "active";
  bool _isLoading = false;

  bool get isEditMode => widget.editAmbulance != null;

  @override
  void initState() {
    super.initState();
    context.read<AmbulanceBloc>().add(const GetAmbulanceFormOptionsEvent());
    if (isEditMode) {
      _loadEditData();
    }
  }

  void _loadEditData() {
    final amb = widget.editAmbulance!;
    _selectedAmbulance = AmbulanceNameOptionEntity(
      id: amb.tabletId,
      name: amb.name,
      categoryId: '',
    );
    _priceController.text = amb.price.toString();
    _discountPriceController.text = amb.discountPrice.toString();
    _selectedFacilities = amb.facilities.map((e) => e.id).toList();
    _status = amb.status.toLowerCase();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAmbulance == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select an ambulance service name')));
      return;
    }

    if (!isEditMode && widget.existingIds.contains(_selectedAmbulance!.id)) {
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

    final payload = {
      "name":
          isEditMode ? widget.editAmbulance!.tabletId : _selectedAmbulance!.id,
      "price": double.tryParse(_priceController.text) ?? 0,
      "discountprice": double.tryParse(_discountPriceController.text) ?? 0,
      "facilities": _selectedFacilities,
      "status": _status,
    };

    if (!isEditMode) {
      payload["categoryId"] = _selectedAmbulance!.categoryId;
    }

    if (isEditMode) {
      context
          .read<AmbulanceBloc>()
          .add(UpdateAmbulanceEvent(widget.editAmbulance!.id, payload));
    } else {
      context.read<AmbulanceBloc>().add(CreateAmbulanceEvent(payload));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AmbulanceBloc, AmbulanceState>(
      listener: (context, state) {
        if (state is AmbulanceFormOptionsLoaded) {
          if (mounted) setState(() => _availableFacilities = state.facilities);
        } else if (state is AmbulanceOperationSuccess) {
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
          widget.onSuccess();
        } else if (state is AmbulanceError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        }
      },
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ambulance Information",
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E1B4B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEditMode
                                ? "Update the ambulance details below"
                                : "Please provide accurate information for the ambulance service",
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 24),
                          _buildNameSearchField(),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: _buildTextField(
                                      "Price per KM", _priceController,
                                      hint: "0.00",
                                      icon: Icons.currency_rupee)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildTextField("Discount Price",
                                      _discountPriceController,
                                      hint: "0.00", icon: Icons.currency_rupee,
                                      validator: (val) {
                                if (val == null || val.isEmpty)
                                  return "Required";
                                final discount = double.tryParse(val);
                                final price =
                                    double.tryParse(_priceController.text);
                                if (discount != null &&
                                    price != null &&
                                    discount > price) {
                                  return "Over price";
                                }
                                return null;
                              })),
                            ],
                          ),
                          const SizedBox(height: 20),
                           if (isEditMode) ...[
                            _buildStatusDropdown(),
                            const SizedBox(height: 20),
                          ],
                          _buildFacilitiesDropdown(_availableFacilities),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.airport_shuttle,
                color: Color(0xFF7C3AED), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? "Edit Ambulance Service" : "Add New Ambulance",
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1B4B)),
                ),
                Text(
                  "Fill in the details for ambulance service",
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Ambulance Service Name",
            isRequired: true, icon: Icons.airport_shuttle_outlined),
        const SizedBox(height: 8),
        if (isEditMode)
          _buildDisabledField(_selectedAmbulance?.name ?? "")
        else
          GestureDetector(
            onTap: _showAmbulanceNamePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedAmbulance?.name ?? "Search Ambulance Service...",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _selectedAmbulance == null
                              ? Colors.grey[400]
                              : Colors.black),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showAmbulanceNamePicker() {
    // Initial fetch for the names
    context.read<AmbulanceBloc>().add(const SearchAmbulanceNamesEvent(""));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AmbulanceBloc>()),
        ],
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Select Ambulance",
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (val) => context
                        .read<AmbulanceBloc>()
                        .add(SearchAmbulanceNamesEvent(val)),
                    decoration: _inputDecoration(hint: "Search...")
                        .copyWith(prefixIcon: const Icon(Icons.search)),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: BlocBuilder<AmbulanceBloc, AmbulanceState>(
                    builder: (context, state) {
                      if (state is AmbulanceNamesSearching) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is AmbulanceNamesSearched) {
                        if (state.names.isEmpty) {
                          return Center(
                              child: Text("No ambulance services found",
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: Colors.grey)));
                        }
                        return ListView.builder(
                          controller: controller,
                          itemCount: state.names.length,
                          itemBuilder: (ctx, i) => ListTile(
                            title: Text(state.names[i].name,
                                style: GoogleFonts.poppins(fontSize: 14)),
                            onTap: () {
                              setState(
                                  () => _selectedAmbulance = state.names[i]);
                              Navigator.pop(ctx);
                            },
                          ),
                        );
                      }
                      return const Center(
                          child: Text("Search for ambulance services"));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {required String hint,
      required IconData icon,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: true, icon: icon),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: _inputDecoration(hint: hint),
          validator: validator ??
              (val) => (val == null || val.isEmpty) ? "Required" : null,
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Status", isRequired: true, icon: Icons.info_outline),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _status,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
          decoration: _inputDecoration(hint: ""),
          items: const [
            DropdownMenuItem(value: "active", child: Text("Active")),
            DropdownMenuItem(value: "inactive", child: Text("Inactive")),
          ],
          onChanged: (val) => setState(() => _status = val!),
        ),
      ],
    );
  }

  Widget _buildFacilitiesDropdown(List<AmbulanceFacilityEntity> facilities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Facilities", isRequired: false, icon: Icons.domain),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showFacilitiesPicker(facilities),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedFacilities.isEmpty
                        ? "Select facilities..."
                        : "${_selectedFacilities.length} facilities selected",
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _selectedFacilities.isEmpty
                            ? Colors.grey[400]
                            : Colors.black),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFacilitiesPicker(List<AmbulanceFacilityEntity> facilities) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Select Facilities",
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: facilities.length,
                    itemBuilder: (ctx, i) {
                      final f = facilities[i];
                      final isSelected = _selectedFacilities.contains(f.id);
                      return CheckboxListTile(
                        title: Text(f.name,
                            style: GoogleFonts.poppins(fontSize: 14)),
                        value: isSelected,
                        onChanged: (val) {
                          setModalState(() {
                            if (val == true) {
                              _selectedFacilities.add(f.id);
                            } else {
                              _selectedFacilities.remove(f.id);
                            }
                          });
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text,
      {bool isRequired = false, required IconData icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
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
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red)),
    );
  }

  Widget _buildDisabledField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!)),
      child: Text(value,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[100]!))),
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
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.airport_shuttle, size: 16),
            label: Text(isEditMode ? "Update Service" : "Add Service",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
