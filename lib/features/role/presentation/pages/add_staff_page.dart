import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_staff_bloc.dart';
import '../bloc/add_staff_event.dart';
import '../bloc/add_staff_state.dart';

import '../../role_injection.dart';

class AddStaffPage extends StatelessWidget {
  final String? employeeId;
  const AddStaffPage({super.key, this.employeeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoleInjection.provideAddStaffBloc()
        ..add(LoadAddStaffFormData(employeeId: employeeId)),
      child: _AddStaffView(employeeId: employeeId),
    );
  }
}

class _AddStaffView extends StatefulWidget {
  final String? employeeId;
  const _AddStaffView({Key? key, this.employeeId}) : super(key: key);

  @override
  State<_AddStaffView> createState() => _AddStaffViewState();
}

class _AddStaffViewState extends State<_AddStaffView> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobPositionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _positionController = TextEditingController();
  final _hireDateController = TextEditingController();
  final _experienceController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedRole;
  List<String> _selectedLanguages = [];
  String? _selectedShift;

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _positionController.dispose();
    _hireDateController.dispose();
    _experienceController.dispose();
    _jobPositionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AddStaffBloc>().add(
            SubmitAddStaff(
              fullName: _fullNameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              password: _passwordController.text,
              address: _addressController.text,
              role: _selectedRole ?? '',
              department: _selectedDepartment ?? '',
              position: _jobPositionController.text,
              hireDate: _hireDateController.text,
              experience: _experienceController.text,
              languages: _selectedLanguages,
              shift: _selectedShift ?? '',
              employeeId: widget.employeeId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person_add_alt_1,
                    color: Colors.purple.shade900, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.employeeId != null
                          ? 'Edit Staff Member'
                          : 'Add New Staff Member',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.employeeId != null
                          ? 'Update staff member information'
                          : 'Create a new staff member profile',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<AddStaffBloc, AddStaffState>(
        listener: (context, state) {
          if (state is AddStaffFormLoaded && state.employee != null) {
            setState(() {
              final emp = state.employee!;
              _fullNameController.text = emp.name;
              _emailController.text = emp.email;
              _phoneController.text = emp.phone;
              _jobPositionController.text =
                  emp.designation; // mapping position to designation
              _addressController.text = emp.address ?? '';
              _selectedRole = emp.role;
              _selectedDepartment = emp.department;

              if (emp.hireDate != null && emp.hireDate!.contains('T')) {
                _hireDateController.text = emp.hireDate!.split('T')[0];
              } else {
                _hireDateController.text = emp.hireDate ?? '';
              }

              _experienceController.text = emp.experience ?? '';

              _selectedLanguages = (emp.languages ?? [])
                  .map((l) => l.isNotEmpty
                      ? l[0].toUpperCase() + l.substring(1).toLowerCase()
                      : l)
                  .toList();

              if (emp.shift != null && emp.shift!.isNotEmpty) {
                String apiShift = emp.shift!;
                _selectedShift = apiShift[0].toUpperCase() +
                    apiShift.substring(1).toLowerCase();
              }
            });
          } else if (state is AddStaffSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(widget.employeeId != null
                    ? 'Staff updated successfully!'
                    : 'Staff added successfully!')));
            Navigator.of(context).pop();
          } else if (state is AddStaffFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
          }
        },
        builder: (context, state) {
          if (state is AddStaffFormLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<String> roleOptions = [
            'Manager',
            'Nurse',
            'Doctor',
            'Pharmacist'
          ];
          List<String> departmentOptions = [
            'Cardiology',
            'Neurology',
            'Pediatrics'
          ];

          if (state is AddStaffFormLoaded) {
            roleOptions = state.roles.map((e) => e.name).toList();
            departmentOptions = state.categories.map((e) => e.name).toList();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Basic Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Personal details and contact information',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14)),
                    const SizedBox(height: 32),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 800;

                        final fFullName = _buildTextField(
                            'Full Name *',
                            _fullNameController,
                            Icons.person_outline,
                            'Enter full name');
                        final fEmail = _buildTextField(
                            'Email Address *',
                            _emailController,
                            Icons.email_outlined,
                            'Enter email address');
                        final fPhone = _buildTextField(
                            'Phone Number *',
                            _phoneController,
                            Icons.phone_outlined,
                            'Enter phone number');
                        final fPassword = _buildTextField(
                            'Password *',
                            _passwordController,
                            Icons.lock_outline,
                            'Enter password',
                            isPassword: true);
                        final fAddress = _buildTextField(
                            'Address',
                            _addressController,
                            Icons.location_on_outlined,
                            'Enter address');
                        final fRole = _buildDropdownField(
                            'Role *',
                            roleOptions,
                            (val) => _selectedRole = val,
                            'Select a role',
                            Icons.badge_outlined,
                            selectedValue: _selectedRole);
                        final fDepartment = _buildDropdownField(
                            'Department *',
                            departmentOptions,
                            (val) => _selectedDepartment = val,
                            'Select a department',
                            Icons.business_outlined,
                            selectedValue: _selectedDepartment);
                        final fPosition = _buildTextField(
                            'Position *',
                            _jobPositionController,
                            Icons.work_outline,
                            'Enter job position');
                        final fHireDate = _buildTextField(
                            'Hire Date',
                            _hireDateController,
                            Icons.calendar_today_outlined,
                            'mm/dd/yyyy',
                            isDate: true);
                        final fExperience = _buildTextField(
                            'Experience (years)',
                            _experienceController,
                            Icons.timeline,
                            'Enter years of experience');
                        final fLanguages = _buildMultiSelectDropdownField(
                            'Languages Spoken',
                            [
                              'Hindi',
                              'English',
                              'Bengali',
                              'Telugu',
                              'Marathi',
                              'Tamil',
                              'Urdu',
                              'Gujarati',
                              'Kannada',
                              'Odia',
                              'Malayalam',
                              'Punjabi'
                            ],
                            _selectedLanguages, (val) {
                          setState(() {
                            if (_selectedLanguages.contains(val)) {
                              _selectedLanguages.remove(val);
                            } else {
                              _selectedLanguages.add(val);
                            }
                          });
                        }, 'Select languages spoken...',
                            Icons.language_outlined);
                        final fShift = _buildDropdownField(
                            'Shift',
                            [
                              'Morning',
                              'Night',
                              'Afternoon',
                              'Evening',
                              'Day',
                              'Flexible'
                            ],
                            (val) => _selectedShift = val,
                            'Select a shift',
                            Icons.access_time);

                        if (isMobile) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              fFullName,
                              const SizedBox(height: 24),
                              fEmail,
                              const SizedBox(height: 24),
                              fPhone,
                              const SizedBox(height: 24),
                              fPassword,
                              const SizedBox(height: 24),
                              fAddress,
                              const SizedBox(height: 24),
                              fRole,
                              const SizedBox(height: 24),
                              fDepartment,
                              const SizedBox(height: 24),
                              fPosition,
                              const SizedBox(height: 24),
                              fHireDate,
                              const SizedBox(height: 24),
                              fExperience,
                              const SizedBox(height: 24),
                              fLanguages,
                              const SizedBox(height: 24),
                              fShift,
                            ],
                          );
                        }

                        final column1 = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            fFullName,
                            const SizedBox(height: 24),
                            fPhone,
                            const SizedBox(height: 24),
                            fAddress,
                            const SizedBox(height: 24),
                            fDepartment,
                            const SizedBox(height: 24),
                            fHireDate,
                            const SizedBox(height: 24),
                            fLanguages,
                          ],
                        );

                        final column2 = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            fEmail,
                            const SizedBox(height: 24),
                            fPassword,
                            const SizedBox(height: 24),
                            fRole,
                            const SizedBox(height: 24),
                            fPosition,
                            const SizedBox(height: 24),
                            fExperience,
                            const SizedBox(height: 24),
                            fShift,
                          ],
                        );

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: column1),
                            const SizedBox(width: 48),
                            Expanded(child: column2),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed:
                              state is AddStaffLoading ? null : _submitForm,
                          icon: state is AddStaffLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.person_add_alt_1,
                                  size: 18, color: Colors.white),
                          label: Text(
                              widget.employeeId != null
                                  ? 'Update Staff Member'
                                  : 'Add Staff Member',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF311B6B),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, String hint,
      {bool isPassword = false, bool isDate = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          readOnly: isDate,
          keyboardType: label.contains('Phone') ? TextInputType.phone : null,
          inputFormatters: label.contains('Phone')
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
              : null,
          onTap: isDate
              ? () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    controller.text =
                        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                  }
                }
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : (isDate
                    ? Icon(Icons.calendar_today_outlined,
                        color: Colors.grey.shade400)
                    : null),
          ),
          validator: (value) {
            if (label.contains('*') && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            if (label == 'Phone Number *' &&
                value != null &&
                value.length < 10) {
              return 'Phone number must be 10 digits';
            }
            if (label == 'Password *' && value != null && value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items,
      Function(String?) onChanged, String hint, IconData icon,
      {String? selectedValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return FormField<String>(
              key: ValueKey(selectedValue),
              initialValue: selectedValue,
              validator: (value) {
                if (label.contains('*') && (value == null || value.isEmpty)) {
                  return 'This field is required';
                }
                return null;
              },
              builder: (FormFieldState<String> field) {
                return PopupMenuButton<String>(
                  initialValue: field.value,
                  onSelected: (String val) {
                    field.didChange(val);
                    onChanged(val);
                  },
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    maxWidth: constraints.maxWidth,
                    maxHeight: 300,
                  ),
                  position: PopupMenuPosition.under,
                  itemBuilder: (BuildContext context) {
                    return items.map((String val) {
                      return PopupMenuItem<String>(
                        value: val,
                        child: Text(val, overflow: TextOverflow.ellipsis),
                      );
                    }).toList();
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      errorText: field.errorText,
                      suffixIcon: Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey.shade400),
                    ),
                    child: Text(
                      field.value ?? hint,
                      style: TextStyle(
                        color: field.value == null
                            ? Colors.grey.shade400
                            : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMultiSelectDropdownField(
      String label,
      List<String> items,
      List<String> selectedItems,
      Function(String) onToggle,
      String hint,
      IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return AlertDialog(
                      title: Text(label),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: items.map((item) {
                            final isSelected = selectedItems.contains(item);
                            return CheckboxListTile(
                              title: Text(item),
                              value: isSelected,
                              onChanged: (bool? checked) {
                                setStateDialog(() {
                                  onToggle(item);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Done'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon:
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
            ),
            child: Text(
              selectedItems.isEmpty ? hint : selectedItems.join(', '),
              style: TextStyle(
                color: selectedItems.isEmpty
                    ? Colors.grey.shade400
                    : Colors.black87,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
