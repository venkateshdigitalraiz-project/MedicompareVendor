import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_new_role_bloc.dart';
import '../bloc/add_new_role_event.dart';
import '../bloc/add_new_role_state.dart';
import '../../role_injection.dart';

import '../../domain/entities/role_entity.dart';

class AddNewRolePage extends StatelessWidget {
  final RoleEntity? role;

  const AddNewRolePage({Key? key, this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoleInjection.provideAddNewRoleBloc(),
      child: _AddNewRoleView(role: role),
    );
  }
}

class _AddNewRoleView extends StatefulWidget {
  final RoleEntity? role;
  const _AddNewRoleView({Key? key, this.role}) : super(key: key);

  @override
  State<_AddNewRoleView> createState() => _AddNewRoleViewState();
}

class _AddNewRoleViewState extends State<_AddNewRoleView> {
  final _formKey = GlobalKey<FormState>();
  final _roleNameController = TextEditingController();
  String? _selectedColorTheme = 'Blue';

  final List<String> _categories = [
    'Staff',
    'Reports',
    'Homecare',
    'Medicine',
    'Medicaltreatment',
    'Ambulanceservice',
    'Medicalequipment',
    'Diagnostics',
    'Labtests',
    'Nursingcare',
    'Coupons',
    'Dentalservice',
    'Surgeries'
  ];

  final List<String> _actions = ['View', 'Add', 'Edit', 'Delete'];

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      _roleNameController.text = widget.role!.name;

      // Attempt to map raw color class to theme name. The predefined options are Blue, Green, Red.
      if (widget.role!.colorTheme.contains('red')) {
        _selectedColorTheme = 'Red';
      } else if (widget.role!.colorTheme.contains('green')) {
        _selectedColorTheme = 'Green';
      } else {
        _selectedColorTheme = 'Blue';
      }

      // Parse permissionsData to initialize Bloc state
      final Map<String, Set<String>> parsedPermissions = {};
      for (var perm in widget.role!.permissionsData) {
        if (perm is Map<String, dynamic>) {
          final module = perm['module'] as String? ?? '';

          // Map to capitalized category matching _categories list
          String matchedCategory = module;
          for (var cat in _categories) {
            if (cat.toLowerCase() == module.toLowerCase()) {
              matchedCategory = cat;
              break;
            }
          }

          final actionsList = perm['actions'] as List<dynamic>? ?? [];
          final Set<String> activeActions = {};

          for (var act in actionsList) {
            if (act is Map<String, dynamic> && act['enabled'] == true) {
              final key = act['key'] as String? ?? '';
              // Capitalize action to match _actions list (e.g., 'view' -> 'View')
              if (key.isNotEmpty) {
                final formattedAction =
                    key[0].toUpperCase() + key.substring(1).toLowerCase();
                if (_actions.contains(formattedAction)) {
                  activeActions.add(formattedAction);
                }
              }
            }
          }
          if (activeActions.isNotEmpty) {
            parsedPermissions[matchedCategory] = activeActions;
          }
        }
      }

      // Fire event to initialize bloc with pre-selected permissions
      context
          .read<AddNewRoleBloc>()
          .add(InitializePermissions(parsedPermissions));
    }
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AddNewRoleBloc>().add(
            SubmitNewRole(
              roleName: _roleNameController.text,
              colorTheme: _selectedColorTheme ?? 'Blue',
              roleId: widget.role?.id,
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
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
                child: Icon(Icons.shield_outlined,
                    color: Colors.purple.shade900, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.role != null ? 'Edit Role' : 'Add New Role',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Expanded(
                      child: Text(
                        widget.role != null
                            ? 'Update the role details below'
                            : 'Fill in the details to add a new role to your system',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<AddNewRoleBloc, AddNewRoleState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Role added successfully!')));
            Navigator.of(context).pop();
          } else if (state.error != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
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
                    const Text('Role Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Please provide accurate information for the role',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14)),
                    const SizedBox(height: 32),
                    // _buildTextField('Role Name *', _roleNameController,
                    //     Icons.badge_outlined, 'Enter role name'),
                    // const SizedBox(height: 16),
                    // _buildDropdownField(
                    //     'Color Theme',
                    //     [
                    //       'Red',
                    //       'Blue',
                    //       'Green',
                    //       'Yellow',
                    //       'Purple',
                    //       "Pink",
                    //       'Indigo',
                    //       'Gray'
                    //     ],
                    //     (val) => _selectedColorTheme = val,
                    //     'Select theme',
                    //     Icons.color_lens_outlined),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                              'Role Name *',
                              _roleNameController,
                              Icons.badge_outlined,
                              'Enter role name'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDropdownField(
                              'Color Theme',
                              [
                                'Red',
                                'Blue',
                                'Green',
                                'Yellow',
                                'Purple',
                                "Pink",
                                'Indigo',
                                'Gray'
                              ],
                              (val) => _selectedColorTheme = val,
                              'Select theme',
                              Icons.color_lens_outlined),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    _buildPermissionsHeader(context, state),
                    const SizedBox(height: 16),
                    _buildPermissionsList(state),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Text('All fields marked with * are required',
                        //     style: TextStyle(
                        //         color: Colors.grey.shade500, fontSize: 13)),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                              ),
                              child: Text('Cancel',
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: state.isSubmitting ? null : _submit,
                              icon: state.isSubmitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.shield_outlined,
                                      size: 18, color: Colors.white),
                              label: Text(
                                  widget.role != null
                                      ? 'Update Role'
                                      : 'Add Role',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF311B6B),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildPermissionsHeader(BuildContext context, AddNewRoleState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.shade100.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.verified_user_rounded,
                size: 20, color: Colors.purple.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Permissions',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text('${state.totalSelected} privileges granted',
                    style: TextStyle(
                        color: Colors.purple.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () => context
                    .read<AddNewRoleBloc>()
                    .add(SelectAllPermissions(_categories, _actions)),
                icon: const Icon(Icons.check_box_outlined, size: 16),
                label: const Text('Select All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.purple.shade700,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    context.read<AddNewRoleBloc>().add(ClearAllPermissions()),
                icon: const Icon(Icons.clear_all_rounded, size: 16),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsList(AddNewRoleState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: _categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final bool isLast = index == _categories.length - 1;

          return Column(
            children: [
              _buildPermissionRow(category, state),
              if (!isLast) Divider(height: 1, color: Colors.grey.shade200),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPermissionRow(String category, AddNewRoleState state) {
    final selectedActions = state.permissions[category] ?? {};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(category,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E293B))),
              const Spacer(),
              Text('${selectedActions.length}/4 granted',
                  style: TextStyle(
                      color: selectedActions.isNotEmpty
                          ? Colors.deepPurple.shade700
                          : Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: selectedActions.isNotEmpty
                          ? FontWeight.w600
                          : FontWeight.normal)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildCheckbox(category, _actions[0],
                      selectedActions.contains(_actions[0]))),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildCheckbox(category, _actions[1],
                      selectedActions.contains(_actions[1]))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildCheckbox(category, _actions[2],
                      selectedActions.contains(_actions[2]))),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildCheckbox(category, _actions[3],
                      selectedActions.contains(_actions[3]))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String category, String action, bool isSelected) {
    return InkWell(
      onTap: () => context
          .read<AddNewRoleBloc>()
          .add(TogglePermission(category, action, !isSelected)),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.purple.shade300 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: isSelected,
                onChanged: (val) {
                  if (val != null) {
                    context
                        .read<AddNewRoleBloc>()
                        .add(TogglePermission(category, action, val));
                  }
                },
                activeColor: Colors.purple.shade700,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                action,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? Colors.purple.shade900
                      : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) {
            if (label.contains('*') && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items,
      Function(String?) onChanged, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.first,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
          items: items.map((String val) {
            return DropdownMenuItem(
              value: val,
              child: Text(val),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
/*
http://192.168.0.161:9002/api/v1/vendor/roles/update/6989a5c48cdf39309b7d7f83  and body 
{"name":"Manager","permission":[{"_id":"6a1d21caafcf73b60589cc4f","serviceId":null,"module":"staff","status":"active","actions":[{"key":"view","enabled":true},{"key":"add","enabled":true},{"key":"edit","enabled":true},{"key":"delete","enabled":true},{"key":"assign","enabled":false}]},{"_id":"6a1d21caafcf73b60589cc50","serviceId":null,"module":"reports","status":"active","actions":[{"key":"view","enabled":true},{"key":"add","enabled":true},{"key":"edit","enabled":true},{"key":"delete","enabled":true},{"key":"assign","enabled":false}]},{"_id":"6a1d21caafcf73b60589cc45","serviceId":"6980ea4057db6637bec0d82d","module":"homecare","status":"active","actions":[{"key":"view","enabled":false},{"key":"add","enabled":false},{"key":"edit","enabled":false},{"key":"delete","enabled":false},{"key":"assign","enabled":false}]},{"_id":"6a1d21caafcf73b60589cc4e","serviceId":"6980ea3f57db6637bec0d800","module":"medicine","status":"active","actions":[{"key":"view","enabled":true},{"key":"add","enabled":false},{"key":"edit","enabled":false},{"key":"delete","enabled":false},{"key":"assign","enabled":true}]},{"_id":"6a1d21caafcf73b60589cc46","serviceId":"6980ea4057db6637bec0d82a","module":"medicaltreatment","status":"active","actions":[{"key":"view","enabled":false},{"key":"add","enabled":false},{"key":"edit","enabled":false},{"key":"delete","enabled":false},{"key":"assign","enabled":false}]},{"_id":"6a1d21caafcf73b60589cc49","serviceId":"6980ea4057db6637bec0d821","module":"ambulanceservice","status":"active","actions":[{"key":"view","enabled":false},{"key":"add","enabled":false},{"key":"edit","enabled":false},{"key":"delete","enabled":false},{"key":"assign","enabled":false}]},{"_id":"6a1d21caafcf73b60589cc47","serviceId":"6980ea4057db6637bec0d827","module":"medicalequipment","status":"active","actions":[{"key":"view","enabled":false},{"key":"add","enabled":false},{"key":"edit","enabled":false},{"key":"delete","enabled":false},{"key":"assign","enabled":false}]},{"_id":"6a1d21caafcf73b60589cc4b","serviceId":"6980ea4057db6637bec0d813","module":"diagnostics","status":"active","actions":[{"key":"view","enabled":false},{"key":"add","enabled":false},{"key":"edit","enabled":false},{"key":"delete","enabled":false},{"key":"assign","enabled":false}]},{"_id":"6a1d21caafcf73b60589cc4c","serviceId":"6980ea4057db6637bec0d80f","module":"labtests","status":"active","actions":[{"key":"view","enabled":false},{"key":"add","enabled":false},{"key":"edit","enabled":false},{"key":"delete","enabled":false},{"key":"assign","enabled":false}]},{"_id":"6a1d21caafcf73b60589cc4a","serviceId":"6980ea4057db6637bec0d81e","module":"nursingcare","status":"active","actions":[{"key":"view","enabled":false},{"key":"add","enabled":false},{"key":"edit","enabled":false},{"key":"delete","enabled":false},{"key":"assign","enabled":false}]},{"_id":"6a1d21caafcf73b60589cc51","serviceId":null,"module":"coupons","status":"active","actions":[{"key":"view","enabled":false},{"key":"add","enabled":false},{"key":"edit","enabled":false},{"key":"delete","enabled":false},{"key":"assign","enabled":false}]},{"_id":"6a1d21caafcf73b60589cc48","serviceId":"6980ea4057db6637bec0d824","module":"dentalservice","status":"active","actions":[{"key":"view","enabled":false},{"key":"add","enabled":false},{"key":"edit","enabled":false},{"key":"delete","enabled":false},{"key":"assign","enabled":false}]},{"_id":"6a1d21caafcf73b60589cc4d","serviceId":"6980ea4057db6637bec0d808","module":"surgeries","status":"active","actions":[{"key":"view","enabled":true},{"key":"add","enabled":true},{"key":"edit","enabled":false},{"key":"delete","enabled":false},{"key":"assign","enabled":true}]}],"color":"bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400","status":"active"}
 */
