import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/create_deliveryman_entity.dart';
import '../bloc/add_deliveryman_bloc.dart';
import '../bloc/add_deliveryman_event.dart';
import '../bloc/add_deliveryman_state.dart';
import '../../deliveryman_injection.dart';

class AddDeliverymanPage extends StatelessWidget {
  const AddDeliverymanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliverymanInjection.provideAddDeliverymanBloc(),
      child: const AddDeliverymanView(),
    );
  }
}

class AddDeliverymanView extends StatefulWidget {
  const AddDeliverymanView({super.key});

  @override
  State<AddDeliverymanView> createState() => _AddDeliverymanViewState();
}

class _AddDeliverymanViewState extends State<AddDeliverymanView> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();
  final _formKey5 = GlobalKey<FormState>();

  int _currentStep = 1;

  // Step 1: Personal Details
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedGender;
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Step 2: Work Details
  String _selectedVehicleType = 'Bike';
  final _vehicleNumberController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _shiftStartController = TextEditingController(text: '09:00 AM');
  final _shiftEndController = TextEditingController(text: '06:00 PM');

  // Step 3: Bank Details
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _ifscController = TextEditingController();
  final _branchController = TextEditingController();

  // Step 4: Proof Documents
  final _aadhaarNumberController = TextEditingController();
  final _panNumberController = TextEditingController();
  File? _aadhaarFile;
  File? _panFile;
  File? _bikeRcFile;
  File? _licenseFile;

  // Step 5: Settings
  String _selectedStatus = 'active';
  bool _autoAssign = true;
  final _maxOrdersController = TextEditingController(text: '20');
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();

    _vehicleNumberController.dispose();
    _licenseNumberController.dispose();
    _shiftStartController.dispose();
    _shiftEndController.dispose();

    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _ifscController.dispose();
    _branchController.dispose();

    _aadhaarNumberController.dispose();
    _panNumberController.dispose();

    _maxOrdersController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(Function(File?) onPicked) async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        setState(() {
          onPicked(File(image.path));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick document: $e')),
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E1B4B),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E1B4B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E1B4B),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E1B4B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      controller.text = '${hour.toString().padLeft(2, '0')}:$minute $period';
    }
  }

  void _onNext() {
    if (_currentStep == 1) {
      if (_formKey1.currentState?.validate() ?? false) {
        setState(() => _currentStep = 2);
      }
    } else if (_currentStep == 2) {
      if (_formKey2.currentState?.validate() ?? false) {
        setState(() => _currentStep = 3);
      }
    } else if (_currentStep == 3) {
      if (_formKey3.currentState?.validate() ?? false) {
        setState(() => _currentStep = 4);
      }
    } else if (_currentStep == 4) {
      if (_formKey4.currentState?.validate() ?? false) {
        setState(() => _currentStep = 5);
      }
    } else if (_currentStep == 5) {
      if (_formKey5.currentState?.validate() ?? false) {
        _submitForm();
      }
    }
  }

  void _onPrevious() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  void _submitForm() {
    final entity = CreateDeliverymanEntity(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      dob: _dobController.text.trim(),
      gender: _selectedGender ?? 'male',
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      vehicleType: _selectedVehicleType,
      vehicleNumber: _vehicleNumberController.text.trim(),
      drivingLicenseNumber: _licenseNumberController.text.trim(),
      shiftStartTime: _shiftStartController.text.trim(),
      shiftEndTime: _shiftEndController.text.trim(),
      bankName: _bankNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      accountHolderName: _accountHolderController.text.trim(),
      ifscCode: _ifscController.text.trim(),
      branchName: _branchController.text.trim(),
      aadhaarNumber: _aadhaarNumberController.text.trim(),
      panNumber: _panNumberController.text.trim(),
      aadhaarDoc: _aadhaarFile?.path,
      panDoc: _panFile?.path,
      bikeRcDoc: _bikeRcFile?.path,
      drivingLicenseDoc: _licenseFile?.path,
      status: _selectedStatus,
      autoAssign: _autoAssign,
      maxDailyOrders: int.tryParse(_maxOrdersController.text.trim()) ?? 20,
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
      notes: _notesController.text.trim(),
    );

    context.read<AddDeliverymanBloc>().add(SubmitAddDeliverymanEvent(entity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 64,
        titleSpacing: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1B4B)),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_add_alt_1_outlined,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Add Deliveryman",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1E1B4B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "Add a new delivery personnel to your team",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
        ),
      ),
      body: BlocConsumer<AddDeliverymanBloc, AddDeliverymanState>(
        listener: (context, state) {
          if (state is AddDeliverymanSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF16A34A),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop(true);
          } else if (state is AddDeliverymanFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is AddDeliverymanSubmitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Stepper Navigation
                _buildStepper(),
                const SizedBox(height: 20),

                // Step Content Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 1) _buildStep1PersonalDetails(),
                      if (_currentStep == 2) _buildStep2WorkDetails(),
                      if (_currentStep == 3) _buildStep3BankDetails(),
                      if (_currentStep == 4) _buildStep4ProofDocuments(),
                      if (_currentStep == 5) _buildStep5Settings(),
                      const SizedBox(height: 28),

                      // Bottom Action Buttons
                      _buildBottomActions(isSubmitting),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepper() {
    final steps = [
      {'num': 1, 'title': 'Personal Details'},
      {'num': 2, 'title': 'Work Details'},
      {'num': 3, 'title': 'Bank Details'},
      {'num': 4, 'title': 'Proof Documents'},
      {'num': 5, 'title': 'Settings'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 650;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                final prevStep = (index ~/ 2) + 1;
                final isDone = _currentStep > prevStep;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: isDone
                        ? const Color(0xFF1E1B4B)
                        : const Color(0xFFE2E8F0),
                  ),
                );
              }

              final stepIndex = index ~/ 2;
              final stepData = steps[stepIndex];
              final stepNum = stepData['num'] as int;
              final isCurrent = _currentStep == stepNum;
              final isDone = _currentStep > stepNum;

              Color circleBg;
              Color circleText;
              if (isCurrent) {
                circleBg = const Color(0xFF1E1B4B);
                circleText = Colors.white;
              } else if (isDone) {
                circleBg = const Color(0xFF1E1B4B);
                circleText = Colors.white;
              } else {
                circleBg = const Color(0xFFF1F5F9);
                circleText = const Color(0xFF94A3B8);
              }

              return InkWell(
                onTap: isDone
                    ? () => setState(() => _currentStep = stepNum)
                    : null,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: circleBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "$stepNum",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: circleText,
                          ),
                        ),
                      ),
                      if (!isCompact) ...[
                        const SizedBox(height: 6),
                        Text(
                          stepData['title'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : (isDone
                                    ? FontWeight.w600
                                    : FontWeight.normal),
                            color: isCurrent
                                ? const Color(0xFF1E1B4B)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildStep1PersonalDetails() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personal Information",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Personal details and contact information",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Name & Email
          _buildResponsiveRow([
            _buildTextField(
              label: "Full Name *",
              hint: "e.g. Rahul Sharma",
              controller: _nameController,
              validator: (val) => val == null || val.trim().isEmpty
                  ? "Full name is required"
                  : null,
            ),
            _buildTextField(
              label: "Email Address *",
              hint: "rahul@example.com",
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (val) => val == null || !val.contains('@')
                  ? "Valid email is required"
                  : null,
            ),
          ]),
          const SizedBox(height: 16),

          // Phone & DOB
          _buildResponsiveRow([
            _buildTextField(
              label: "Phone Number *",
              hint: "10-digit mobile number",
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return "Phone number is required";
                }
                if (val.trim().length != 10) {
                  return "Phone number must be exactly 10 digits";
                }
                return null;
              },
            ),
            _buildTextField(
              label: "Date of Birth *",
              hint: "Select Date",
              controller: _dobController,
              readOnly: true,
              onTap: _selectDate,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              validator: (val) => val == null || val.trim().isEmpty
                  ? "Date of birth is required"
                  : null,
            ),
          ]),
          const SizedBox(height: 16),

          // Gender
          _buildDropdownField(
            label: "Gender *",
            hint: "Select Gender",
            value: _selectedGender,
            items: const ['Male', 'Female', 'Other'],
            onChanged: (val) => setState(() => _selectedGender = val),
            validator: (val) => val == null ? "Gender is required" : null,
          ),
          const SizedBox(height: 16),

          // Full Address
          _buildTextField(
            label: "Full Address *",
            hint: "Enter house/flat no., street address, locality",
            controller: _addressController,
            maxLines: 3,
            validator: (val) => val == null || val.trim().isEmpty
                ? "Full address is required"
                : null,
          ),
          const SizedBox(height: 16),

          // City, State, Pincode
          _buildResponsiveRow([
            _buildTextField(
              label: "City *",
              hint: "e.g. Hyderabad",
              controller: _cityController,
              validator: (val) =>
                  val == null || val.trim().isEmpty ? "City is required" : null,
            ),
            _buildTextField(
              label: "State *",
              hint: "e.g. Telangana",
              controller: _stateController,
              validator: (val) => val == null || val.trim().isEmpty
                  ? "State is required"
                  : null,
            ),
          ]),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Pincode *",
            hint: "6-digit Pincode",
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (val) => val == null || val.trim().length != 6
                ? "Valid 6-digit pincode is required"
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2WorkDetails() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Work Information",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Specify vehicle details and preferred working shift",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Vehicle Type & Vehicle Number
          _buildResponsiveRow([
            _buildDropdownField(
              label: "Vehicle Type *",
              hint: "Select Vehicle Type",
              value: _selectedVehicleType,
              items: const ['Bike', 'Scooter', 'Car', 'Van', 'Electric Bike'],
              onChanged: (val) =>
                  setState(() => _selectedVehicleType = val ?? 'Bike'),
            ),
            _buildTextField(
              label: "Vehicle Number *",
              hint: "E.G. TS21F2987",
              controller: _vehicleNumberController,
              textCapitalization: TextCapitalization.characters,
              validator: (val) => val == null || val.trim().isEmpty
                  ? "Vehicle number is required"
                  : null,
            ),
          ]),
          const SizedBox(height: 16),

          // Driving License Number
          _buildTextField(
            label: "Driving License Number *",
            hint: "E.G. MH1220210012345",
            controller: _licenseNumberController,
            textCapitalization: TextCapitalization.characters,
            validator: (val) => val == null || val.trim().isEmpty
                ? "Driving license number is required"
                : null,
          ),
          const SizedBox(height: 16),

          // Shift timings
          _buildResponsiveRow([
            _buildTextField(
              label: "Working Shift Start Time",
              hint: "09:00 AM",
              controller: _shiftStartController,
              readOnly: true,
              onTap: () => _selectTime(_shiftStartController),
              suffixIcon: const Icon(Icons.access_time, size: 18),
            ),
            _buildTextField(
              label: "Working Shift End Time",
              hint: "06:00 PM",
              controller: _shiftEndController,
              readOnly: true,
              onTap: () => _selectTime(_shiftEndController),
              suffixIcon: const Icon(Icons.access_time, size: 18),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildStep3BankDetails() {
    return Form(
      key: _formKey3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bank Account Information",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Provide account details for delivery payout transfers",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Bank Name & Account Number
          _buildResponsiveRow([
            _buildTextField(
              label: "Bank Name *",
              hint: "e.g. State Bank of India",
              controller: _bankNameController,
              validator: (val) => val == null || val.trim().isEmpty
                  ? "Bank name is required"
                  : null,
            ),
            _buildTextField(
              label: "Account Number *",
              hint: "Enter bank account number",
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              validator: (val) => val == null || val.trim().isEmpty
                  ? "Account number is required"
                  : null,
            ),
          ]),
          const SizedBox(height: 16),

          // Account Holder Name & IFSC Code
          _buildResponsiveRow([
            _buildTextField(
              label: "Account Holder Name *",
              hint: "Name as per bank passbook",
              controller: _accountHolderController,
              validator: (val) => val == null || val.trim().isEmpty
                  ? "Account holder name is required"
                  : null,
            ),
            _buildTextField(
              label: "IFSC Code *",
              hint: "E.G. SBIN0001234",
              controller: _ifscController,
              textCapitalization: TextCapitalization.characters,
              validator: (val) => val == null || val.trim().isEmpty
                  ? "IFSC code is required"
                  : null,
            ),
          ]),
          const SizedBox(height: 16),

          // Branch Name
          _buildTextField(
            label: "Branch Name",
            hint: "Enter branch name",
            controller: _branchController,
          ),
        ],
      ),
    );
  }

  Widget _buildStep4ProofDocuments() {
    return Form(
      key: _formKey4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Proof Documents",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Upload government ID proofs and vehicle registration cards",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Aadhaar Number & PAN Number
          _buildResponsiveRow([
            _buildTextField(
              label: "Aadhaar Number *",
              hint: "XXXX XXXX XXXX",
              controller: _aadhaarNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              validator: (val) => val == null || val.trim().length != 12
                  ? "Valid 12-digit Aadhaar number is required"
                  : null,
            ),
            _buildTextField(
              label: "PAN Number *",
              hint: "ABCDE1234F",
              controller: _panNumberController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (val) => val == null || val.trim().length != 10
                  ? "Valid 10-character PAN number is required"
                  : null,
            ),
          ]),

          const SizedBox(height: 20),

          // Upload Document Cards
          _buildResponsiveRow([
            _buildUploadCard(
              title: "Aadhaar Card Document *",
              file: _aadhaarFile,
              onTap: () => _pickDocument((f) => _aadhaarFile = f),
            ),
            _buildUploadCard(
              title: "PAN Card Document *",
              file: _panFile,
              onTap: () => _pickDocument((f) => _panFile = f),
            ),
          ]),
          const SizedBox(height: 16),

          _buildResponsiveRow([
            _buildUploadCard(
              title: "Bike RC Document *",
              file: _bikeRcFile,
              onTap: () => _pickDocument((f) => _bikeRcFile = f),
            ),
            _buildUploadCard(
              title: "Driving License Document *",
              file: _licenseFile,
              onTap: () => _pickDocument((f) => _licenseFile = f),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildStep5Settings() {
    return Form(
      key: _formKey5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Settings & Permissions",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Configure operational settings and account preferences",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Status & Max Orders
          _buildResponsiveRow([
            _buildDropdownField(
              label: "Account Status *",
              hint: "Select Status",
              value: _selectedStatus,
              items: const ['active', 'inactive'],
              onChanged: (val) =>
                  setState(() => _selectedStatus = val ?? 'active'),
            ),
            _buildTextField(
              label: "Max Daily Deliveries",
              hint: "e.g. 20",
              controller: _maxOrdersController,
              keyboardType: TextInputType.number,
            ),
          ]),
          const SizedBox(height: 16),

          // Auto-assignment Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Allow Auto-Assignment",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    Switch(
                      value: _autoAssign,
                      activeThumbColor: const Color(0xFF1E1B4B),
                      onChanged: (val) => setState(() => _autoAssign = val),
                    ),
                  ],
                ),
                Text(
                  "Automatically allocate nearby orders to this personnel",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Emergency Contact
          _buildResponsiveRow([
            _buildTextField(
              label: "Emergency Contact Name",
              hint: "e.g. Family Member Name",
              controller: _emergencyNameController,
            ),
            _buildTextField(
              label: "Emergency Contact Phone",
              hint: "10-digit mobile number",
              controller: _emergencyPhoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (val) {
                if (val != null &&
                    val.trim().isNotEmpty &&
                    val.trim().length != 10) {
                  return "Emergency phone must be 10 digits";
                }
                return null;
              },
            ),
          ]),
          const SizedBox(height: 16),

          // Notes
          _buildTextField(
            label: "Special Instructions / Notes",
            hint:
                "Any additional notes regarding shift or location preferences...",
            controller: _notesController,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(bool isSubmitting) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () => context.pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF64748B),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text("Cancel"),
        ),
        Row(
          children: [
            if (_currentStep > 1) ...[
              OutlinedButton.icon(
                onPressed: _onPrevious,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E1B4B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text("Previous"),
              ),
              const SizedBox(width: 12),
            ],
            ElevatedButton(
              onPressed: isSubmitting ? null : _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1B4B),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentStep == 5 ? "Submit" : "Next",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (_currentStep < 5) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward, size: 16),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    if (!label.contains('*')) {
      return Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E1B4B),
        ),
      );
    }

    final baseText = label.replaceAll('*', '').trimRight();
    return Text.rich(
      TextSpan(
        text: baseText,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E1B4B),
        ),
        children: [
          TextSpan(
            text: ' *',
            style: GoogleFonts.inter(
              color: const Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: file != null
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFCBD5E1),
                style: BorderStyle.solid,
              ),
            ),
            child: file != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF16A34A), size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          file.path.split('/').last.split('\\').last,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E1B4B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Change",
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6366F1),
                            decoration: TextDecoration.underline),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.upload_outlined,
                          color: Color(0xFF6366F1),
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Click to upload or drag and drop",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                      Text(
                        "JPG, PNG or PDF (Max 5MB)",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(children.length * 2 - 1, (index) {
              if (index.isOdd) return const SizedBox(height: 16);
              return children[index ~/ 2];
            }),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(children.length * 2 - 1, (index) {
            if (index.isOdd) return const SizedBox(width: 16);
            return Expanded(child: children[index ~/ 2]);
          }),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          style:
              GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1E1B4B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF1E1B4B), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: Text(
            hint,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
          ),
          items: items.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(
                e[0].toUpperCase() + e.substring(1),
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF1E1B4B)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF1E1B4B), width: 1.5),
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
