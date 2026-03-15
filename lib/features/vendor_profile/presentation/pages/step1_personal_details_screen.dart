import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/vendor_profile_provider.dart';
import '../../vendor_profile_injection.dart';

class Step1PersonalDetailsScreen extends StatefulWidget {
  const Step1PersonalDetailsScreen({super.key});

  @override
  State<Step1PersonalDetailsScreen> createState() => _Step1PersonalDetailsScreenState();
}

class _Step1PersonalDetailsScreenState extends State<Step1PersonalDetailsScreen> {
  String? selectedIdProofType;
  final List<String> idProofTypes = [
    'Aadhaar',
    'Passport',
    'Driving License',
    'Voter ID',
    'PAN Card'
  ];

  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  PlatformFile? frontFile;
  PlatformFile? backFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vendor =
          Provider.of<VendorProfileProvider>(context, listen: false).vendor;
      if (vendor != null) {
        setState(() {
          if (vendor.proofType != null) {
            final matched = idProofTypes.firstWhere(
              (type) => type.toLowerCase() == vendor.proofType!.toLowerCase(),
              orElse: () => idProofTypes.first,
            );
            selectedIdProofType = matched;
          }
          idNumberController.text = vendor.adhaarNumber ?? "";
          addressController.text = vendor.residentialAddress ?? "";
        });
      }
    });
  }

  @override
  void dispose() {
    idNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isFront) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (isFront) {
          frontFile = result.files.single;
        } else {
          backFile = result.files.single;
        }
      });
    }
  }

  void _handleSubmit() async {
    if (selectedIdProofType == null ||
        idNumberController.text.isEmpty ||
        frontFile == null ||
        backFile == null ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload images')),
      );
      return;
    }

    final provider = Provider.of<VendorProfileProvider>(context, listen: false);

    final frontXFile = frontFile!.path != null 
        ? XFile(frontFile!.path!) 
        : XFile.fromData(frontFile!.bytes!, name: frontFile!.name);
    
    final backXFile = backFile!.path != null 
        ? XFile(backFile!.path!) 
        : XFile.fromData(backFile!.bytes!, name: backFile!.name);

    final success = await provider.updateStepOne(
      proofType: selectedIdProofType!.toLowerCase(),
      idNumber: idNumberController.text.trim(),
      frontImage: frontXFile,
      backImage: backXFile,
      residentialAddress: addressController.text.trim(),
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Step 1 updated successfully!')),
      );
      if (provider.vendor?.registrationStep == 'step2') {
        context.push('/step2-business-details');
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
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Complete Your Vendor Profile",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please provide the following information to set up your account",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
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
    );
  }

  Widget _buildStepper() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _stepIcon(Icons.person, "Personal\nDetails", true),
          _stepLine(false),
          _stepIcon(Icons.apartment, "Business\nDetails", false),
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

  Widget _stepIcon(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isActive ? AppColors.primary : Colors.grey[200],
          child: Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 20),
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
      color: isCompleted ? AppColors.primary : Colors.grey[200],
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
              "Personal Details",
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text("Identity Verification:", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("ID Proof Type *"),
                      _buildDropdown(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("ID Proof Number *"),
                      _buildTextField(idNumberController, "Enter ID Number"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("ID Proof Front *"),
                      _buildUploadBox(true),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("ID Proof Back *"),
                      _buildUploadBox(false),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _label("Residential Address *"),
            _buildTextField(addressController, "Enter your complete residential address", maxLines: 3),
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

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text("Select ID Proof Type", style: TextStyle(fontSize: 13, color: Colors.grey[400])),
          value: selectedIdProofType,
          items: idProofTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 13)));
          }).toList(),
          onChanged: (value) => setState(() => selectedIdProofType = value),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
    );
  }

  Widget _buildUploadBox(bool isFront) {
    final file = isFront ? frontFile : backFile;
    return GestureDetector(
      onTap: () => _pickFile(isFront),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(8),
        dashPattern: const [6, 3],
        color: Colors.grey[400]!,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 100,
            width: double.infinity,
            color: Colors.grey[50],
            child: file != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            file.extension == 'pdf' ? Icons.picture_as_pdf : Icons.description,
                            color: AppColors.primary,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              file.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[800]),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => isFront ? frontFile = null : backFile = null),
                          child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 14, color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_file, color: AppColors.primary, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        isFront ? "Click to upload front doc" : "Click to upload back doc",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[600]),
                      ),
                      Text(
                        "(PDF, Word, Excel)",
                        style: GoogleFonts.inter(fontSize: 8, color: Colors.grey[400]),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Consumer<VendorProfileProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: null, // Disabled for step 1
                icon: const Icon(Icons.arrow_back),
                label: const Text("Previous"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: provider.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
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
