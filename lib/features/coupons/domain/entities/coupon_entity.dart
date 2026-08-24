class Coupon {
  final String? id;
  final String couponCode;
  final String selectionType;
  final int? userLimit;
  final String renewalCycle;
  final String couponName;
  final String discountType;
  final double discountValue;
  final double? minimumPurchaseAmount;
  final double? maximumDiscountAmount;
  final DateTime validFrom;
  final DateTime validTo;
  final String status;
  final bool hiddenCoupon;
  final String description;
  final String? userId;
  final String? applicableType;
  final String? category;

  const Coupon({
    this.id,
    required this.couponCode,
    required this.selectionType,
    this.userLimit,
    required this.renewalCycle,
    required this.couponName,
    required this.discountType,
    required this.discountValue,
    this.minimumPurchaseAmount,
    this.maximumDiscountAmount,
    required this.validFrom,
    required this.validTo,
    required this.status,
    required this.hiddenCoupon,
    this.description = '',
    this.userId,
    this.applicableType,
    this.category = 'all',
  });
}
