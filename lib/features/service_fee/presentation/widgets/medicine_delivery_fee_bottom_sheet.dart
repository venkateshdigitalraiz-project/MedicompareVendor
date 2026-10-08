import 'package:MediCompare/features/service_fee/presentation/bloc/service_fee_event.dart';
import 'package:MediCompare/features/service_fee/presentation/bloc/service_fee_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MediCompare/core/constants/app_colors.dart';
import '../bloc/service_fee_bloc.dart';
import '../../domain/entities/medicine_delivery_fee.dart';
import '../../domain/entities/service_fee.dart';
import '../../domain/entities/medical_equipment_delivery_fee.dart';
import '../../domain/entities/lab_test_visit_fee.dart';

class MedicineDeliveryFeeBottomSheet extends StatefulWidget {
  final ServiceFee serviceFee;
  final Function(ServiceFee)?
      onSave; // Make optional if they want to rely on the internal bloc

  const MedicineDeliveryFeeBottomSheet({
    Key? key,
    required this.serviceFee,
    this.onSave,
  }) : super(key: key);

  @override
  State<MedicineDeliveryFeeBottomSheet> createState() =>
      _MedicineDeliveryFeeBottomSheetState();
}

class _MedicineDeliveryFeeBottomSheetState
    extends State<MedicineDeliveryFeeBottomSheet> {
  // Medicine
  late final TextEditingController minDeliveryFeeCtrl;
  late final TextEditingController baseRadiusCtrl;
  late final TextEditingController perKmChargeCtrl;
  late final TextEditingController minOrderCtrl;

  // Equipment
  late final TextEditingController eqMinDeliveryFeeCtrl;
  late final TextEditingController eqBaseRadiusCtrl;
  late final TextEditingController eqPerKmChargeCtrl;

  // Lab Tests
  late String labTestVisitType;
  late final TextEditingController labHomeVisitFeeCtrl;

  @override
  void initState() {
    super.initState();
    // Medicine
    minDeliveryFeeCtrl = TextEditingController(
        text: widget.serviceFee.medicine?.minDeliveryFee.toInt().toString() ??
            "0");
    baseRadiusCtrl = TextEditingController(
        text: widget.serviceFee.medicine?.baseRadius.toInt().toString() ?? "0");
    perKmChargeCtrl = TextEditingController(
        text:
            widget.serviceFee.medicine?.perKmCharge.toInt().toString() ?? "0");
    minOrderCtrl = TextEditingController(
        text: widget.serviceFee.medicine?.minOrderForFreeDelivery
                .toInt()
                .toString() ??
            "0");

    // Equipment
    eqMinDeliveryFeeCtrl = TextEditingController(
        text: widget.serviceFee.medicalEquipment?.minDeliveryFee
                .toInt()
                .toString() ??
            "0");
    eqBaseRadiusCtrl = TextEditingController(
        text:
            widget.serviceFee.medicalEquipment?.baseRadius.toInt().toString() ??
                "0");
    eqPerKmChargeCtrl = TextEditingController(
        text: widget.serviceFee.medicalEquipment?.perKmCharge
                .toInt()
                .toString() ??
            "0");

    // Lab Tests
    String rawVisitType = widget.serviceFee.labTests?.visitType ?? "Both";
    if (rawVisitType.isEmpty) rawVisitType = "Both";

    if (rawVisitType.toLowerCase().contains("home")) {
      labTestVisitType = "Home Visit";
    } else if (rawVisitType.toLowerCase().contains("lab")) {
      labTestVisitType = "Lab Visit";
    } else {
      labTestVisitType = "Both";
    }

    labHomeVisitFeeCtrl = TextEditingController(
        text:
            widget.serviceFee.labTests?.homeVisitFee.toInt().toString() ?? "0");
  }

  @override
  void dispose() {
    minDeliveryFeeCtrl.dispose();
    baseRadiusCtrl.dispose();
    perKmChargeCtrl.dispose();
    minOrderCtrl.dispose();
    eqMinDeliveryFeeCtrl.dispose();
    eqBaseRadiusCtrl.dispose();
    eqPerKmChargeCtrl.dispose();
    labHomeVisitFeeCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    final oldMed = widget.serviceFee.medicine;
    final newMedFee = MedicineDeliveryFee(
      minDeliveryFee: double.tryParse(minDeliveryFeeCtrl.text) ??
          oldMed?.minDeliveryFee ??
          0,
      baseRadius:
          double.tryParse(baseRadiusCtrl.text) ?? oldMed?.baseRadius ?? 0,
      perKmCharge:
          double.tryParse(perKmChargeCtrl.text) ?? oldMed?.perKmCharge ?? 0,
      minOrderForFreeDelivery: double.tryParse(minOrderCtrl.text) ??
          oldMed?.minOrderForFreeDelivery ??
          0,
    );

    final oldEq = widget.serviceFee.medicalEquipment;
    final newEqFee = MedicalEquipmentDeliveryFee(
      minDeliveryFee: double.tryParse(eqMinDeliveryFeeCtrl.text) ??
          oldEq?.minDeliveryFee ??
          0,
      baseRadius:
          double.tryParse(eqBaseRadiusCtrl.text) ?? oldEq?.baseRadius ?? 0,
      perKmCharge:
          double.tryParse(eqPerKmChargeCtrl.text) ?? oldEq?.perKmCharge ?? 0,
      minOrderForFreeDelivery: oldEq?.minOrderForFreeDelivery ?? 0,
    );

    String apiVisitType = labTestVisitType.toLowerCase();
    if (apiVisitType.contains("home")) {
      apiVisitType = "home";
    } else if (apiVisitType.contains("lab")) {
      apiVisitType = "lab";
    } else {
      apiVisitType = "both";
    }

    final oldLab = widget.serviceFee.labTests;
    final newLabFee = LabTestVisitFee(
      visitType: apiVisitType,
      homeVisitFee: double.tryParse(labHomeVisitFeeCtrl.text) ??
          oldLab?.homeVisitFee ??
          0,
      urgentSurcharge: oldLab?.urgentSurcharge ?? 0,
      maxRadius: oldLab?.maxRadius ?? 0,
    );

    final state = context.read<ServiceFeeBloc>().state;
    if (state is ServiceFeeSuccess || state is ServiceFeeRefreshing) {
      final currentServiceFee = state is ServiceFeeSuccess
          ? state.serviceFee
          : (state as ServiceFeeRefreshing).serviceFee;

      final updatedServiceFee = ServiceFee(
        id: currentServiceFee.id,
        vendorId: currentServiceFee.vendorId,
        createdAt: currentServiceFee.createdAt,
        updatedAt: currentServiceFee.updatedAt,
        user: currentServiceFee.user,
        branchOverrides: currentServiceFee.branchOverrides,
        medicine: newMedFee,
        medicalEquipment: newEqFee,
        labTests: newLabFee,
      );

      context.read<ServiceFeeBloc>().add(SaveServiceFee(updatedServiceFee));
    }

    if (widget.onSave != null) {
      widget.onSave!(widget
          .serviceFee); // Keeping this for backward compatibility if callers expect it
    }

    Navigator.pop(context);
  }

  void _handleReset() {
    setState(() {
      // Medicines
      minDeliveryFeeCtrl.text = "40";
      baseRadiusCtrl.text = "5";
      perKmChargeCtrl.text = "8";
      minOrderCtrl.text = "500";

      // Medical Equipment
      eqMinDeliveryFeeCtrl.text = "150";
      eqBaseRadiusCtrl.text = "8";
      eqPerKmChargeCtrl.text = "15";

      // Lab Tests
      labTestVisitType = "Both";
      labHomeVisitFeeCtrl.text = "150";
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping_outlined,
                        color: AppColors.primaryDark, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Medicines Parameters",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Configure standard fee settings for this category",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.greyText.withOpacity(0.2)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildItem(
                      label: "Minimum Delivery Fee (₹) *",
                      controller: minDeliveryFeeCtrl,
                      prefixText: "₹ ",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildItem(
                      label: "Base Delivery Radius / Min Km *",
                      controller: baseRadiusCtrl,
                      suffixText: " km",
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildItem(
                      label: "Per Kilometer Charge After Base Radius (₹/km) *",
                      controller: perKmChargeCtrl,
                      prefixText: "₹ ",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildItem(
                      label: "Minimum Order for Free Delivery (₹)",
                      controller: minOrderCtrl,
                      prefixText: "₹ ",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Equipment Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping_outlined,
                        color: AppColors.primaryDark, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Medical Equipment Parameters",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Configure standard fee settings for this category",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.greyText.withOpacity(0.2)),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildItem(
                      label: "Minimum Delivery Fee (₹) *",
                      controller: eqMinDeliveryFeeCtrl,
                      prefixText: "₹ ",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildItem(
                      label: "Base Delivery Radius / Min Km *",
                      controller: eqBaseRadiusCtrl,
                      suffixText: " km",
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildItem(
                      label: "Per Kilometer Charge After Base Radius (₹/km) *",
                      controller: eqPerKmChargeCtrl,
                      prefixText: "₹ ",
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(child: SizedBox()),
                ],
              ),

              const SizedBox(height: 24),

              // Lab Tests Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune_outlined,
                        color: AppColors.primaryDark, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lab Tests Parameters",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Configure standard fee settings for this category",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.greyText.withOpacity(0.2)),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDropdownItem(
                      label: "Visit Options / Booking Mode *",
                      value: labTestVisitType,
                      items: ["Both", "Home Visit", "Lab Visit"],
                      onChanged: (val) {
                        setState(() {
                          labTestVisitType = val!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildItem(
                      label: "Standard Home Visit Fee (₹) *",
                      controller: labHomeVisitFeeCtrl,
                      prefixText: "₹ ",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: AppColors.primaryDark),
                      ),
                      onPressed: _handleReset,
                      child: Text(
                        "Reset",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: AppColors.primaryDark),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _handleSave,
                      child: Text(
                        "Save",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required String label,
    required TextEditingController controller,
    String? prefixText,
    String? suffixText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              prefixText: prefixText,
              suffixText: suffixText,
              prefixStyle: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
              suffixStyle: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: AppColors.greyText.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: AppColors.greyText.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    // Ensure the value exists in the list to prevent assertion errors
    if (!items.contains(value)) {
      final match =
          items.where((item) => item.toLowerCase() == value.toLowerCase());
      if (match.isNotEmpty) {
        value = match.first;
      } else if (items.contains("Both")) {
        value = "Both";
      } else {
        value = items.first;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            items: items
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.black,
                            fontWeight: FontWeight.w600))))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppColors.greyText.withOpacity(0.3))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppColors.greyText.withOpacity(0.3))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryDark)),
            ),
          ),
        ],
      ),
    );
  }
}
/*
medicines Parameters
1. minimum delivery charge -40
2. base radius  5KM
3. charge per km -8
4. minimum order amount for free delivery -500

medical equipment Parameters
1. Minimum Delivery Fee (₹) -150
2. Base Delivery Radius / Min Km - 8 KM
3. Per Kilometer Charge After Base Radius (₹/km) * -15

lab tests Parameters
1. Visit Options / Booking Mode -both
2.Standard Home Visit Fee 150
 */
