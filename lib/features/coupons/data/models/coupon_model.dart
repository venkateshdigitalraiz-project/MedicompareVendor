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
    super.description,
    super.userId,
    super.applicableType,
    super.category,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    String parseSelectionType(String? val) {
      if (val == 'user') return 'User';
      if (val == 'branch') return 'Branch';
      if (val == 'all') return 'All';
      return val ?? 'User';
    }

    String parseRenewalCycle(String? val) {
      if (val == 'never' || val == '1') return 'Never (One-time)';
      if (val == 'daily') return 'Daily';
      if (val == 'weekly' || val == '7') return 'Weekly';
      if (val == 'monthly') return 'Monthly';
      if (val == 'yearly') return 'Yearly';
      return val ?? 'Never (One-time)';
    }

    String parseDiscountType(String? val) {
      if (val == 'percentage') return 'Percentage (%)';
      if (val == 'flat' || val == 'fixed') return 'Fixed Amount(₹)';
      return val ?? 'Percentage (%)';
    }

    String parseStatus(String? val) {
      if (val == 'active') return 'Active';
      if (val == 'inactive') return 'Inactive';
      return val ?? 'Active';
    }

    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString());
    }

    return CouponModel(
      id: json['id'] ?? json['_id'],
      couponCode: json['couponCode'] ?? json['code'] ?? '',
      selectionType: parseSelectionType(json['selectionType'] ?? json['categoryType']),
      userLimit: parseInt(json['userLimit'] ?? json['usageLimit']),
      renewalCycle: parseRenewalCycle(json['renewalCycle'] ?? json['userRenewal']),
      couponName: json['couponName'] ?? json['name'] ?? '',
      discountType: parseDiscountType(json['discountType']),
      discountValue: parseDouble(json['discountValue'] ?? json['discount']) ?? 0.0,
      minimumPurchaseAmount: parseDouble(json['minimumPurchaseAmount'] ?? json['minimumPurchase']),
      maximumDiscountAmount: parseDouble(json['maximumDiscountAmount'] ?? json['maximumDiscount']),
      validFrom: json['validFrom'] != null 
          ? DateTime.parse(json['validFrom']) 
          : (json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now()),
      validTo: json['validTo'] != null 
          ? DateTime.parse(json['validTo']) 
          : (json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now()),
      status: parseStatus(json['status']),
      hiddenCoupon: json['hiddenCoupon'] ?? json['isHidden'] ?? false,
      description: json['description']?.toString() ?? '',
      userId: json['userId']?.toString() ?? (json['customerId'] is Map ? json['customerId']['_id']?.toString() : json['customerId']?.toString()),
      applicableType: json['applicableType']?.toString() ?? json['selectionType']?.toString(),
      category: json['category']?.toString() ?? 'all',
    );
  }

  Map<String, dynamic> toJson() {
    String mapSelectionType(String val) {
      switch (val) {
        case 'User': return 'user';
        case 'Branch': return 'branch';
        case 'All': return 'all';
        default: return val.toLowerCase();
      }
    }

    String mapRenewalCycle(String val) {
      if (val.contains('Never')) return '1';
      if (val.contains('Daily')) return '1';
      if (val.contains('Weekly')) return '7';
      if (val.contains('Monthly')) return '30';
      if (val.contains('Yearly')) return '365';
      return '1';
    }

    String mapDiscountType(String val) {
      if (val.contains('Percentage') || val.contains('Percent')) return 'percentage';
      if (val.contains('Fixed') || val.contains('Flat')) return 'fixed';
      return val.toLowerCase();
    }

    String mapStatus(String val) {
      return val.toLowerCase();
    }

    return {
      'code': couponCode,
      'name': couponName,
      'description': description,
      'discountType': mapDiscountType(discountType),
      'discount': discountValue,
      'minimumPurchase': minimumPurchaseAmount ?? 0.0,
      'maximumDiscount': maximumDiscountAmount,
      'startDate': validFrom.toIso8601String(),
      'endDate': validTo.toIso8601String(),
      'selectionType': mapSelectionType(selectionType),
      'usageLimit': userLimit ?? 10,
      'userRenewal': mapRenewalCycle(renewalCycle),
      if (userId != null) 'userId': userId,
      'applicableType': applicableType ?? mapSelectionType(selectionType),
      'category': category ?? 'all',
      'status': mapStatus(status),
      'isHidden': hiddenCoupon,
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
      description: entity.description,
      userId: entity.userId,
      applicableType: entity.applicableType,
      category: entity.category,
    );
  }
}
