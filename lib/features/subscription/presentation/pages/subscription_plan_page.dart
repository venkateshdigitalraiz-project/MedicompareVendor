import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:MediCompare/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:MediCompare/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscriptionPlanPage extends StatefulWidget {
  const SubscriptionPlanPage({super.key});

  @override
  State<SubscriptionPlanPage> createState() => _SubscriptionPlanPageState();
}

class _SubscriptionPlanPageState extends State<SubscriptionPlanPage> {
  late Razorpay _razorpay;
  static const String _razorpayKey = "rzp_test_RsHwplQ9ACSY5s";

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External wallet selected: ${response.walletName}")),
    );
  }

  void _openCheckout(String orderId, int amount, String planName) {
    var options = {
      'key': _razorpayKey,
      'amount': amount * 100, // Amount is in paise
      'name': 'MediCompare',
      'description': planName,
      'timeout': 300, // in seconds
      'prefill': {
        'contact': '', // Optional: Fill from user profile
        'email': '', // Optional: Fill from user profile
      }
    };

    if (orderId.isNotEmpty) {
      options['order_id'] = orderId;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is OrderCreated) {
          if (Navigator.of(context).canPop())
            Navigator.of(context).pop(); // Close loading dialog
          _openCheckout(state.orderId, state.amount, state.plan.name);
        } else if (state is OrderFailure) {
          if (Navigator.of(context).canPop())
            Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Failed to initiate payment: ${state.message}")),
          );
        } else if (state is PurchaseSuccess) {
          if (Navigator.of(context).canPop())
            Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Plan upgraded successfully!")),
          );
        } else if (state is OrderProcessing || state is PurchaseProcessing) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );
        } else if (state is SubscriptionError) {
          if (Navigator.of(context).canPop())
            Navigator.of(context).pop(); // Close loading dialog
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FF),
        appBar: AppBar(
          backgroundColor: AppColors.primaryDark,
          elevation: 0,
          title: Text(
            "My Subscription Plan",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          buildWhen: (previous, current) =>
              current is SubscriptionLoading ||
              current is SubscriptionLoaded ||
              current is SubscriptionError,
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SubscriptionLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<SubscriptionBloc>()
                      .add(LoadSubscriptionDataEvent());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 24),
                      Text(
                        "Available Plans",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E1B4B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...state.plans.list.map((plan) {
                        final isCurrentPlan =
                            state.history.currentPack?.planId == plan.id;
                        return _buildPlanCard(plan, isCurrentPlan);
                      }).toList(),
                      const SizedBox(height: 32),
                      if (state.history.planHistory.isNotEmpty) ...[
                        Text(
                          "Plan History",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1B4B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...state.history.planHistory
                            .map((history) => _buildHistoryItem(history))
                            .toList(),
                      ],
                    ],
                  ),
                ),
              );
            } else if (state is SubscriptionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<SubscriptionBloc>()
                            .add(LoadSubscriptionDataEvent());
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // To capture plan info for success callback
  dynamic _selectedPlan;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_selectedPlan != null && response.paymentId != null) {
      context.read<SubscriptionBloc>().add(PurchasePlanEvent(
            planId: _selectedPlan.id,
            razorpayPaymentId: response.paymentId!,
            amount: _selectedPlan.price.toInt(),
          ));
    }
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lead Subscription Plans",
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Choose a plan to continue accessing lead management features.",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(dynamic plan, bool isCurrentPlan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentPlan
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.name,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              if (isCurrentPlan)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Current Plan",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "₹",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "${plan.price.toInt()}",
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "${plan.limit} Leads limit",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          ...plan.features
              .map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 18, color: Color(0xFF8B5CF6)),
                        const SizedBox(width: 8),
                        Text(
                          feature,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrentPlan
                  ? null
                  : () {
                      _selectedPlan = plan;
                      context.read<SubscriptionBloc>().add(CreateOrderEvent(
                            amount: plan.price.toInt(),
                            currency: "INR",
                            receipt:
                                "plan_${DateTime.now().millisecondsSinceEpoch}",
                            plan: plan,
                          ));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCurrentPlan ? const Color(0xFFE5E7EB) : AppColors.primary,
                foregroundColor:
                    isCurrentPlan ? Colors.grey[600] : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                isCurrentPlan ? "Current Plan" : "Upgrade Plan",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(dynamic history) {
    final date = DateFormat('dd MMM yyyy').format(history.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.history, color: Color(0xFF8B5CF6), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.plan?.name ?? "Subscription",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                Text(
                  "Status: ${history.paymentStatus}",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: history.paymentStatus == 'completed'
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${history.amount.toInt()}",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              Text(
                date,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
