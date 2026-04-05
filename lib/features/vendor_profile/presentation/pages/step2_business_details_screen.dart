import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_colors.dart';
import '../providers/vendor_profile_provider.dart';

class Step2BusinessDetailsScreen extends StatefulWidget {
  const Step2BusinessDetailsScreen({super.key});

  @override
  State<Step2BusinessDetailsScreen> createState() =>
      _Step2BusinessDetailsScreenState();
}

class _Step2BusinessDetailsScreenState
    extends State<Step2BusinessDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController legalNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController altMobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController searchAddressController = TextEditingController();

  Country selectedCountry = Country.parse('IN');
  Country? selectedAltCountry;

  final List<String> categories = [
    'Medicine',
    'Surgeries',
    'Lab Tests',
    'Diagnostics',
    'Nursing Care',
    'Ambulance Service',
    'Dental Service',
    'Medical Equipment',
    'Medical Treatment',
    'Home Care',
    'Homecare Services'
  ];
  List<String> selectedCategories = [];

  double lat = 0.0;
  double lng = 0.0;
  String? placeId;
  List<dynamic> predictions = [];
  bool isSearchingAddress = false;

  final String googleApiKey = 'AIzaSyCrQfumXF2fKkdxz0Z1SRD-9XlAthO3vZs';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vendor =
          Provider.of<VendorProfileProvider>(context, listen: false).vendor;
      if (vendor != null) {
        setState(() {
          displayNameController.text = vendor.businessName ?? "";
          legalNameController.text = vendor.businessLegalName ?? "";
          emailController.text = vendor.businessEmail ?? "";
          addressController.text = vendor.businessAddress ?? "";
          searchAddressController.text = vendor.businessAddress ?? "";

          if (vendor.businessMobile != null &&
              vendor.businessMobile!.isNotEmpty) {
            // Very basic phone parsing, assuming +91 for now or trying to match
            if (vendor.businessMobile!.startsWith("+")) {
              // This is complex without a library, but I'll try to match phone code
            } else {
              mobileController.text = vendor.businessMobile!;
            }
          }

          if (vendor.altMobile != null) {
            altMobileController.text = vendor.altMobile!;
          }

          if (vendor.categoryIds != null) {
            selectedCategories = List<String>.from(vendor.categoryIds!);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    displayNameController.dispose();
    legalNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    altMobileController.dispose();
    addressController.dispose();
    searchAddressController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress(String input) async {
    if (input.isEmpty) {
      setState(() => predictions = []);
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey&components=country:in';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          predictions = data['predictions'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching predictions: $e");
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'];
        final location = result['geometry']['location'];
        final formattedAddress = result['formatted_address'];

        setState(() {
          lat = location['lat'];
          lng = location['lng'];
          addressController.text = formattedAddress;
          predictions = [];
          searchAddressController.text = formattedAddress;
        });
      }
    } catch (e) {
      debugPrint("Error fetching place details: $e");
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
      );
      return;
    }

    final provider = Provider.of<VendorProfileProvider>(context, listen: false);

    final success = await provider.updateStepTwo(
      name: displayNameController.text.trim(),
      businessLegalName: legalNameController.text.trim(),
      email: emailController.text.trim(),
      mobile: "${selectedCountry.phoneCode}${mobileController.text.trim()}",
      altMobile: altMobileController.text.isNotEmpty
          ? "${selectedAltCountry?.phoneCode ?? selectedCountry.phoneCode}${altMobileController.text.trim()}"
          : null,
      address: addressController.text.trim(),
      lat: lat,
      lng: lng,
      categoryIds: selectedCategories, // Using names as IDs for now
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Step 2 updated successfully!')),
      );
      if (provider.vendor?.registrationStep == 'step3') {
        context.push('/step3-banking-info');
      }
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Image.asset('assets/medi_compare_logo.png', height: 40),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading:
            BackButton(color: Colors.black, onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Complete Your Vendor Profile",
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Please provide the following information to set up your account",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              _buildStepper(),
              const SizedBox(height: 32),
              _buildFormCard(),
              const SizedBox(height: 32),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _stepIcon(Icons.check_circle, "Personal\nDetails", true,
              isCompleted: true),
          _stepLine(true),
          _stepIcon(Icons.apartment, "Business\nDetails", true),
          _stepLine(false),
          _stepIcon(Icons.account_balance, "Banking\nInfo", false),
          _stepLine(false),
          _stepIcon(Icons.description, "Docs &\nCerts", false),
          _stepLine(false),
          _stepIcon(Icons.image, "Store\nImages", false),
          _stepLine(false),
          _stepIcon(Icons.edit, "Digital\nSignature", false),
        ],
      ),
    );
  }

  Widget _stepIcon(IconData icon, String label, bool isActive,
      {bool isCompleted = false}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isCompleted
              ? Colors.green
              : (isActive ? AppColors.primary : Colors.grey[200]),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: (isActive || isCompleted) ? Colors.white : Colors.grey,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool isCompleted) {
    return Container(
      width: 30,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted ? Colors.green : Colors.grey[200],
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Business Details",
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _label("Business Display Name *"),
            _buildTextField(displayNameController, "e.g. Wane Enterprises",
                validator: (v) => v!.isEmpty ? "Required" : null),
            const SizedBox(height: 16),
            _label("Business Legal Name *"),
            _buildTextField(legalNameController, "Enter Business Legal Name",
                validator: (v) => v!.isEmpty ? "Required" : null),
            const SizedBox(height: 16),
            _label("Business Email *"),
            _buildTextField(emailController, "e.g. work@example.com",
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || !v.contains('@')) ? "Invalid email" : null),
            const SizedBox(height: 16),
            _label("Business Mobile Number *"),
            _buildPhoneField(mobileController, selectedCountry,
                (c) => setState(() => selectedCountry = c)),
            const SizedBox(height: 16),
            _label("Alternate Business Mobile Number (Optional)"),
            _buildPhoneField(
                altMobileController,
                selectedAltCountry ?? selectedCountry,
                (c) => setState(() => selectedAltCountry = c)),
            const SizedBox(height: 16),
            _label("Business Categories *"),
            _buildCategorySelector(),
            if (selectedCategories.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: selectedCategories
                    .map((cat) => Chip(
                          label:
                              Text(cat, style: const TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () =>
                              setState(() => selectedCategories.remove(cat)),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            _label("Business Address *"),
            _buildAddressSearchField(),
            const SizedBox(height: 16),
            _label("Business Address (Editable) *"),
            _buildTextField(addressController,
                "Address will be auto-filled or enter manually",
                maxLines: 3, validator: (v) => v!.isEmpty ? "Required" : null),
            const SizedBox(height: 8),
            Text(
              "This address will be sent to the backend. You can edit it as needed.",
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
    );
  }

  Widget _buildPhoneField(TextEditingController controller, Country country,
      Function(Country) onCountrySelected) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => showCountryPicker(
            context: context,
            onSelect: onCountrySelected,
            showPhoneCode: true,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(country.flagEmoji),
                const SizedBox(width: 4),
                Text("+${country.phoneCode}",
                    style: const TextStyle(fontSize: 13)),
                const Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
            child: _buildTextField(controller, "9876543210",
                keyboardType: TextInputType.phone)),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setModalState) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Select Business Categories",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = selectedCategories.contains(cat);
                        return CheckboxListTile(
                          title: Text(cat),
                          value: isSelected,
                          onChanged: (val) {
                            setModalState(() {
                              if (val!) {
                                selectedCategories.add(cat);
                              } else {
                                selectedCategories.remove(cat);
                              }
                            });
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            });
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedCategories.isEmpty
                  ? "Select your business categories"
                  : "${selectedCategories.length} selected",
              style: TextStyle(
                  fontSize: 13,
                  color: selectedCategories.isEmpty
                      ? Colors.grey[400]
                      : Colors.black),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSearchField() {
    return Column(
      children: [
        TextFormField(
          controller: searchAddressController,
          onChanged: _searchAddress,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: "Search address with Google Maps...",
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            prefixIcon: const Icon(Icons.search, size: 20),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        ),
        if (predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                final prediction = predictions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on,
                      size: 18, color: Colors.grey),
                  title: Text(prediction['description'],
                      style: const TextStyle(fontSize: 12)),
                  onTap: () => _getPlaceDetails(prediction['place_id']),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Consumer<VendorProfileProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Previous"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Next",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
