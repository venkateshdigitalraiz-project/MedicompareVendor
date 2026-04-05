import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/utils/token_storage.dart';
import '../bloc/pincodes_bloc.dart';
import '../bloc/pincodes_event.dart';
import '../bloc/pincodes_state.dart';
import '../../domain/entities/pincode_entity.dart';

class PincodesPage extends StatelessWidget {
  const PincodesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PincodesBloc, PincodesState>(
      listener: (context, state) {
        if (state is PincodesError && state.message.contains('UNAUTHORIZED')) {
          TokenStorage.clearAll().then((_) {
            if (context.mounted) {
              context.go('/login');
            }
          });
        }
        if (state is PincodeCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Pincode added successfully!"),
                backgroundColor: Colors.green),
          );
        }
        if (state is PincodeUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Pincode updated successfully!"),
                backgroundColor: Colors.green),
          );
        }
        if (state is PincodeDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Pincode deleted successfully!"),
                backgroundColor: Colors.green),
          );
        }
        if (state is PincodeOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<PincodesBloc, PincodesState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF3F6FF),
            appBar: const CustomHomeAppBar(
              title: "Pincode Management",
              subtitle: "Manage your service area pincodes",
            ),
            body: _buildMainContent(context, state),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddEditDropdown(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, PincodesState state) {
    if (state is PincodesLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PincodesLoaded) {
      return _buildContent(context, state.pincodes);
    } else if (state is PincodesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<PincodesBloc>().add(GetPincodesEvent()),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildContent(BuildContext context, List<PincodeDataEntity> pincodes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: pincodes.isEmpty
              ? Center(
                  child: Text(
                    "No pincodes found",
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: pincodes.length,
                  itemBuilder: (context, index) {
                    return _buildPincodeCard(context, pincodes[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPincodeCard(BuildContext context, PincodeDataEntity item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(Icons.location_on, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.pincode.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () =>
                        _showAddEditDropdown(context, pincode: item),
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.blue, size: 18),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showDeleteConfirmation(context, item),
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18),
                  ),
                ],
              ),
            ],
          ),
          // const SizedBox(height: 10),
          // const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.local_shipping_outlined,
                      size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Est. Delivery",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        item.estimatedDelivery,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.status == 'active'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: item.status == 'active' ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddEditDropdown(BuildContext context,
      {PincodeDataEntity? pincode}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<PincodesBloc>(),
          child: AddEditPincodeDialog(pincode: pincode),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, PincodeDataEntity item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Delete Pincode",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Text(
              "Are you sure you want to delete pincode ${item.pincode.name}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child:
                  Text("Cancel", style: GoogleFonts.inter(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<PincodesBloc>()
                    .add(DeletePincodeEvent(id: item.id));
                Navigator.pop(dialogContext);
              },
              child: Text("Delete",
                  style: GoogleFonts.inter(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

class AddEditPincodeDialog extends StatefulWidget {
  final PincodeDataEntity? pincode;
  const AddEditPincodeDialog({super.key, this.pincode});

  @override
  State<AddEditPincodeDialog> createState() => _AddEditPincodeDialogState();
}

class _AddEditPincodeDialogState extends State<AddEditPincodeDialog> {
  late TextEditingController _pincodeController;
  late TextEditingController _deliveryController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _pincodeController =
        TextEditingController(text: widget.pincode?.pincode.name ?? '');
    _deliveryController =
        TextEditingController(text: widget.pincode?.estimatedDelivery ?? '');
    _status = widget.pincode?.status ?? 'active';
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.pincode != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? "Edit Pincode" : "Add Pincode",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFieldLabel("Pincode *", Icons.location_on_outlined),
            const SizedBox(height: 8),
            _buildTextField(_pincodeController, "Enter Pincode",
                readOnly: isEdit),
            const SizedBox(height: 16),
            _buildFieldLabel(
                "Estimated Delivery *", Icons.local_shipping_outlined),
            const SizedBox(height: 8),
            _buildTextField(_deliveryController, "e.g. Within 2 Days"),
            const SizedBox(height: 16),
            _buildFieldLabel("Status *", Icons.check_circle_outline),
            const SizedBox(height: 8),
            _buildStatusDropdown(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.inter(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_pincodeController.text.isNotEmpty &&
                        _deliveryController.text.isNotEmpty) {
                      if (isEdit) {
                        context.read<PincodesBloc>().add(
                              UpdatePincodeEvent(
                                id: widget.pincode!.id,
                                pincode: _pincodeController.text,
                                estimatedDelivery: _deliveryController.text,
                                status: _status,
                              ),
                            );
                      } else {
                        context.read<PincodesBloc>().add(
                              CreatePincodeEvent(
                                pincode: _pincodeController.text,
                                estimatedDelivery: _deliveryController.text,
                                status: _status,
                              ),
                            );
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Save",
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[100] : null,
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      style: GoogleFonts.inter(fontSize: 14),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _status,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'active', child: Text("Active")),
            DropdownMenuItem(value: 'inactive', child: Text("Inactive")),
          ],
          onChanged: (val) {
            setState(() {
              _status = val!;
            });
          },
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
        ),
      ),
    );
  }
}
