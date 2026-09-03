import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:MediCompare/core/constants/app_colors.dart';
import '../../domain/entities/medicine_delivery_fee.dart';

class MedicineDeliveryFeeBottomSheet extends StatefulWidget {
  final MedicineDeliveryFee fee;
  final Function(MedicineDeliveryFee) onSave;

  const MedicineDeliveryFeeBottomSheet({
    Key? key,
    required this.fee,
    required this.onSave,
  }) : super(key: key);

  @override
  State<MedicineDeliveryFeeBottomSheet> createState() => _MedicineDeliveryFeeBottomSheetState();
}

class _MedicineDeliveryFeeBottomSheetState extends State<MedicineDeliveryFeeBottomSheet> {
  late final TextEditingController minDeliveryFeeCtrl;
  late final TextEditingController baseRadiusCtrl;
  late final TextEditingController perKmChargeCtrl;
  late final TextEditingController minOrderCtrl;

  @override
  void initState() {
    super.initState();
    minDeliveryFeeCtrl = TextEditingController(text: widget.fee.minDeliveryFee.toInt().toString());
    baseRadiusCtrl = TextEditingController(text: widget.fee.baseRadius.toInt().toString());
    perKmChargeCtrl = TextEditingController(text: widget.fee.perKmCharge.toInt().toString());
    minOrderCtrl = TextEditingController(text: widget.fee.minOrderForFreeDelivery.toInt().toString());
  }

  @override
  void dispose() {
    minDeliveryFeeCtrl.dispose();
    baseRadiusCtrl.dispose();
    perKmChargeCtrl.dispose();
    minOrderCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    final newFee = MedicineDeliveryFee(
      minDeliveryFee: double.tryParse(minDeliveryFeeCtrl.text) ?? widget.fee.minDeliveryFee,
      baseRadius: double.tryParse(baseRadiusCtrl.text) ?? widget.fee.baseRadius,
      perKmCharge: double.tryParse(perKmChargeCtrl.text) ?? widget.fee.perKmCharge,
      minOrderForFreeDelivery: double.tryParse(minOrderCtrl.text) ?? widget.fee.minOrderForFreeDelivery,
    );
    widget.onSave(newFee);
  }

  @override
  Widget build(BuildContext context) {
    // Add bottom padding for keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Medicine Delivery Fee",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildItem(
                label: "Minimum Delivery Fee (₹) *",
                controller: minDeliveryFeeCtrl,
                prefixText: "₹ ",
              ),
              _buildItem(
                label: "Base Delivery Radius / Min Km *",
                controller: baseRadiusCtrl,
                suffixText: " km",
              ),
              _buildItem(
                label: "Per Kilometer Charge After Base Radius (₹/km) *",
                controller: perKmChargeCtrl,
                prefixText: "₹ ",
              ),
              _buildItem(
                label: "Minimum Order for Free Delivery (₹)",
                controller: minOrderCtrl,
                prefixText: "₹ ",
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.greyText.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.greyText.withOpacity(0.3)),
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
}
