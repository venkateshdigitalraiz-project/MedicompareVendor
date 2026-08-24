import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:MediCompare/core/constants/app_colors.dart';
import '../../domain/entities/service_fee_user.dart';
import '../bloc/service_fee_bloc.dart';
import '../bloc/service_fee_event.dart';
import '../bloc/service_fee_state.dart';
import '../widgets/medicine_delivery_fee_card.dart';
import '../widgets/medical_equipment_fee_card.dart';
import '../widgets/lab_test_visit_fee_card.dart';

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
      ),
      body: BlocBuilder<ServiceFeeBloc, ServiceFeeState>(
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
}
