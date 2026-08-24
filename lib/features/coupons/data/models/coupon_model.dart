import '../../domain/entities/coupon_entity.dart';

class CouponModel extends Coupon {
  const CouponModel({
    super.id,
    required super.couponCode,
    required super.selectionType,
    super.userLimit,
    required super.renewalCycle,
    required super.couponName,
    required super.discountType,
    required super.discountValue,
    super.minimumPurchaseAmount,
    super.maximumDiscountAmount,
    required super.validFrom,
    required super.validTo,
    required super.status,
    required super.hiddenCoupon,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'],
      couponCode: json['couponCode'],
      selectionType: json['selectionType'],
      userLimit: json['userLimit'],
      renewalCycle: json['renewalCycle'],
      couponName: json['couponName'],
      discountType: json['discountType'],
      discountValue: (json['discountValue'] as num).toDouble(),
      minimumPurchaseAmount: json['minimumPurchaseAmount'] != null ? (json['minimumPurchaseAmount'] as num).toDouble() : null,
      maximumDiscountAmount: json['maximumDiscountAmount'] != null ? (json['maximumDiscountAmount'] as num).toDouble() : null,
      validFrom: DateTime.parse(json['validFrom']),
      validTo: DateTime.parse(json['validTo']),
      status: json['status'],
      hiddenCoupon: json['hiddenCoupon'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'couponCode': couponCode,
      'selectionType': selectionType,
      'userLimit': userLimit,
      'renewalCycle': renewalCycle,
      'couponName': couponName,
      'discountType': discountType,
      'discountValue': discountValue,
      if (minimumPurchaseAmount != null) 'minimumPurchaseAmount': minimumPurchaseAmount,
      if (maximumDiscountAmount != null) 'maximumDiscountAmount': maximumDiscountAmount,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo.toIso8601String(),
      'status': status,
      'hiddenCoupon': hiddenCoupon,
    };
  }

  factory CouponModel.fromEntity(Coupon entity) {
    return CouponModel(
      id: entity.id,
      couponCode: entity.couponCode,
      selectionType: entity.selectionType,
      userLimit: entity.userLimit,
      renewalCycle: entity.renewalCycle,
      couponName: entity.couponName,
      discountType: entity.discountType,
      discountValue: entity.discountValue,
      minimumPurchaseAmount: entity.minimumPurchaseAmount,
      maximumDiscountAmount: entity.maximumDiscountAmount,
      validFrom: entity.validFrom,
      validTo: entity.validTo,
      status: entity.status,
      hiddenCoupon: entity.hiddenCoupon,
    );
  }
}
