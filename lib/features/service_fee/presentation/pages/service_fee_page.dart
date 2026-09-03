import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:MediCompare/core/constants/app_colors.dart';
import '../../domain/entities/service_fee_user.dart';
import '../../domain/entities/service_fee.dart';
import '../bloc/service_fee_bloc.dart';
import '../bloc/service_fee_event.dart';
import '../bloc/service_fee_state.dart';
import '../widgets/medicine_delivery_fee_card.dart';
import '../widgets/medical_equipment_fee_card.dart';
import '../widgets/lab_test_visit_fee_card.dart';
import '../widgets/medicine_delivery_fee_bottom_sheet.dart';


class ServiceFeePage extends StatefulWidget {
  const ServiceFeePage({super.key});

  @override
  State<ServiceFeePage> createState() => _ServiceFeePageState();
}

class _ServiceFeePageState extends State<ServiceFeePage> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceFeeBloc>().add(LoadServiceFee());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Service Fee",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        actions: [
          BlocBuilder<ServiceFeeBloc, ServiceFeeState>(
            builder: (context, state) {
              if (state is ServiceFeeActionLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                    ),
                  ),
                );
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if ((state is ServiceFeeSuccess && state.serviceFee.medicine != null) || 
                      (state is ServiceFeeRefreshing && state.serviceFee.medicine != null))
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (sheetContext) {
                            final currentFee = state is ServiceFeeSuccess 
                                ? state.serviceFee 
                                : (state as ServiceFeeRefreshing).serviceFee;
                                
                            return MedicineDeliveryFeeBottomSheet(
                              fee: currentFee.medicine!,
                              onSave: (updatedMedicineFee) {
                                final updatedServiceFee = ServiceFee(
                                  id: currentFee.id,
                                  vendorId: currentFee.vendorId,
                                  createdAt: currentFee.createdAt,
                                  updatedAt: currentFee.updatedAt,
                                  user: currentFee.user,
                                  labTests: currentFee.labTests,
                                  medicalEquipment: currentFee.medicalEquipment,
                                  branchOverrides: currentFee.branchOverrides,
                                  medicine: updatedMedicineFee,
                                );
                                context.read<ServiceFeeBloc>().add(SaveServiceFee(updatedServiceFee));
                                Navigator.pop(sheetContext); // Close the bottom sheet
                              },
                            );
                          },
                        );
                      },
                    ),
                  TextButton(
                    onPressed: () {
                      if (state is ServiceFeeSuccess) {
                        context.read<ServiceFeeBloc>().add(SaveServiceFee(state.serviceFee));
                      }
                    },
                    child: Text(
                      "Save",
                      style: GoogleFonts.inter(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showResetDialog(),
                    child: Text(
                      "Reset",
                      style: GoogleFonts.inter(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ServiceFeeBloc, ServiceFeeState>(
        listener: (context, state) {
          if (state is ServiceFeeUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<ServiceFeeBloc>().add(LoadServiceFee());
          } else if (state is ServiceFeeFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ServiceFeeInitial || state is ServiceFeeLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryDark),
            );
          }

          if (state is ServiceFeeFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.red),
                    const SizedBox(height: 16),
                    Text(
                      "Unable to load service fee",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.greyText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        context.read<ServiceFeeBloc>().add(LoadServiceFee());
                      },
                      child: Text(
                        "Retry",
                        style: GoogleFonts.inter(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ServiceFeeSuccess || state is ServiceFeeRefreshing) {
            final serviceFee = (state is ServiceFeeSuccess)
                ? state.serviceFee
                : (state as ServiceFeeRefreshing).serviceFee;

            final hasUser = serviceFee.user != null;
            final hasMedicine = serviceFee.medicine != null;
            final hasEquipment = serviceFee.medicalEquipment != null;
            final hasLabTests = serviceFee.labTests != null;

            if (!hasMedicine && !hasEquipment && !hasLabTests && !hasUser) {
              return Center(
                child: Text(
                  "No service fee configuration available.",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.greyText,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primaryDark,
              onRefresh: () async {
                context.read<ServiceFeeBloc>().add(RefreshServiceFee());
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (hasUser) _buildVendorHeader(serviceFee.user!),
                  if (hasMedicine) MedicineDeliveryFeeCard(fee: serviceFee.medicine!),
                  if (hasEquipment) MedicalEquipmentFeeCard(fee: serviceFee.medicalEquipment!),
                  if (hasLabTests) LabTestVisitFeeCard(fee: serviceFee.labTests!),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildVendorHeader(ServiceFeeUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryDark.withOpacity(0.1),
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'V',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.businessName ?? user.businessLegalName ?? user.fullName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                if (user.businessName != null || user.businessLegalName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.fullName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.mail_outline, size: 14, color: AppColors.greyText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        user.email,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.greyText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.phone_outlined, size: 14, color: AppColors.greyText),
                    const SizedBox(width: 4),
                    Text(
                      user.mobile,
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.greyText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "vendor medicompare.com says",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to reset all service fee parameters to defaults?",
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(color: AppColors.greyText),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<ServiceFeeBloc>().add(ResetServiceFee());
              },
              child: Text(
                "OK",
                style: GoogleFonts.inter(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
