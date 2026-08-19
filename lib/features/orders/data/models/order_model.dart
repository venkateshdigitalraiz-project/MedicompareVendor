import '../../domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.orderItemId,
    required super.orderId,
    required super.productId,
    required super.quantity,
    required super.type,
    required super.bookingType,
    required super.orderStatus,
    required super.paymentStatus,
    required super.price,
    required super.discountPrice,
    required super.totalPrice,
    required super.vendorCommissionAmount,
    required super.createdAt,
    required super.orderDetails,
    required super.productDetails,
    super.userDetails,
    super.shippingAddressDetails,
    super.billingAddressDetails,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['_id']?.toString() ?? '',
      orderItemId: json['orderItemId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      type: json['type']?.toString() ?? '',
      bookingType: json['bookingType']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      // API may use camelCase or snake_case for discount price
      discountPrice:
          (json['discountPrice'] ?? json['discountprice'] ?? 0).toDouble(),
      // API may use camelCase or snake_case for total price
      totalPrice: (() {
        final billing = json['billingSummary'] ?? {};
        final unitPrice = billing['unitPrice'];
        if (unitPrice != null && unitPrice != 0)
          return (unitPrice as num).toDouble();
        return ((json['total'] ?? json['totalPrice'] ?? json['totalprice'] ?? 0)
                as num)
            .toDouble();
      })(),
      // API may use camelCase or snake_case for vendor commission amount
      vendorCommissionAmount: (json['vendorCommissionAmount'] ??
              json['vendorcommissionamount'] ??
              0)
          .toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      orderDetails: OrderDetailsModel.fromJson(
          json['orderDetails'] ?? <String, dynamic>{}),
      productDetails: ProductDetailsModel.fromJson(
          json['productDetails'] ?? <String, dynamic>{}),
      userDetails: json['userDetails'] != null
          ? FullUserDetailsModel.fromJson(json['userDetails'])
          : null,
      shippingAddressDetails: json['shippingAddressDetails'] != null
          ? AddressDetailsModel.fromJson(json['shippingAddressDetails'])
          : null,
      billingAddressDetails: json['billingAddressDetails'] != null
          ? AddressDetailsModel.fromJson(json['billingAddressDetails'])
          : null,
    );
  }
}

class OrderDetailsModel extends OrderDetailsEntity {
  const OrderDetailsModel({
    required super.id,
    required super.orderId,
    required super.userId,
    required super.paymentMethod,
    required super.paymentStatus,
    required super.orderStatus,
    required super.subtotal,
    required super.total,
    super.shipping = 0,
    super.discount = 0,
    super.tax = 0,
    super.cgst = 0,
    super.sgst = 0,
    required super.personType,
    super.doctorName,
    super.userDetails,
    super.fixedDeposit = 0,
    super.serviceCharges = 0,
    super.returnCharge = 0,
    super.rentalPlan,
    super.paymentType,
    super.startDate,
    super.endDate,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      id: json['_id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      paymentMethod: json['paymentmethod']?.toString() ??
          json['paymentMethod']?.toString() ??
          '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      shipping: (json['shipping'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      cgst: (json['cgst'] ?? 0).toDouble(),
      sgst: (json['sgst'] ?? 0).toDouble(),
      personType: json['persontype']?.toString() ?? '',
      doctorName: json['doctorName']?.toString(),
      userDetails: json['userDetails'] != null
          ? UserDetailsModel.fromJson(json['userDetails'])
          : null,
      fixedDeposit: (json['fixedDeposit'] ?? 0).toDouble(),
      serviceCharges: (json['serviceCharges'] ?? 0).toDouble(),
      returnCharge: (json['returnCharge'] ?? 0).toDouble(),
      rentalPlan: json['rentalPlan']?.toString(),
      paymentType: json['paymentType']?.toString(),
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
}

// Simple user details model used in OrderDetailsEntity
class UserDetailsModel extends UserDetailsEntity {
  const UserDetailsModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
  });

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    // Handle combined name if first/last are missing
    String firstName = json['first_name']?.toString() ?? '';
    String lastName = json['last_name']?.toString() ?? '';
    if ((firstName.isEmpty && lastName.isEmpty) && json['name'] != null) {
      final parts = json['name'].toString().split(' ');
      if (parts.isNotEmpty) {
        firstName = parts.first;
        if (parts.length > 1) {
          lastName = parts.sublist(1).join(' ');
        }
      }
    }
    return UserDetailsModel(
      id: json['_id']?.toString() ?? '',
      firstName: firstName,
      lastName: lastName,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class FullUserDetailsModel extends FullUserDetailsEntity {
  const FullUserDetailsModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.age,
    required super.gender,
    required super.files,
  });

  factory FullUserDetailsModel.fromJson(Map<String, dynamic> json) {
    // Handle combined name if first/last not present
    String firstName = json['first_name']?.toString() ?? '';
    String lastName = json['last_name']?.toString() ?? '';
    if ((firstName.isEmpty && lastName.isEmpty) && json['name'] != null) {
      final fullName = json['name'].toString();
      final parts = fullName.split(' ');
      if (parts.isNotEmpty) {
        firstName = parts.first;
        if (parts.length > 1) {
          lastName = parts.sublist(1).join(' ');
        }
      }
    }
    return FullUserDetailsModel(
      id: json['_id']?.toString() ?? '',
      firstName: firstName,
      lastName: lastName,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      age: json['age'] ?? 0,
      gender: json['gender']?.toString() ?? '',
      files: (json['files'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class AddressDetailsModel extends AddressDetailsEntity {
  const AddressDetailsModel({
    required super.id,
    required super.houseNo,
    required super.area,
    required super.landmark,
    required super.description,
    required super.addressType,
    required super.pincode,
    required super.fullAddress,
  });

  factory AddressDetailsModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    return AddressDetailsModel(
      id: json['_id']?.toString() ?? '',
      houseNo: json['houseNo']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      addressType: json['addressType']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      fullAddress: location['address']?.toString() ?? '',
    );
  }
}

class ProductDetailsModel extends ProductDetailsEntity {
  const ProductDetailsModel({
    required super.id,
    required super.name,
    super.tabletDetails,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailsModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tabletDetails: json['tabletDetails'] ?? json['tabletdetails'],
    );
  }
}

class PaginationModel extends PaginationEntity {
  const PaginationModel({
    required super.total,
    required super.page,
    required super.limit,
    required super.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class OrdersListModel extends OrdersListEntity {
  const OrdersListModel({
    required super.orderItems,
    required super.pagination,
  });

  factory OrdersListModel.fromJson(Map<String, dynamic> json) {
    // API may return orders under different keys (e.g., 'orderitems' or 'orders').
    final List<dynamic> ordersJson = json['orderitems'] ?? json['orders'] ?? [];
    final List<dynamic> flattenedItems = [];
    for (var order in ordersJson) {
      final String orderId = order['_id']?.toString() ?? '';
      final String orderRef = order['orderRef']?.toString() ?? '';
      final String orderStatus = order['orderStatus']?.toString() ?? '';
      final String paymentStatus = order['paymentStatus']?.toString() ?? '';
      final String bookingType = order['bookingType']?.toString() ?? '';
      final DateTime createdAt = order['createdAt'] != null
          ? DateTime.parse(order['createdAt'])
          : DateTime.now();

      // The API doesn't send a nested "orderDetails" object — it puts those
      // fields directly on the order. Build that object here from the
      // order-level fields so OrderDetailsModel.fromJson actually has data
      // to parse instead of silently defaulting everything to empty/zero.
      final Map<String, dynamic> orderDetailsJson = {
        '_id': orderId,
        'orderId': orderId,
        'userId': order['userDetails']?['_id']?.toString() ?? '',
        'paymentmethod': order['paymentMethod'] ?? order['paymentmethod'],
        'paymentStatus': paymentStatus,
        'orderStatus': orderStatus,
        'subtotal': order['subtotal'] ?? 0,
        'total': order['total'] ?? 0,
        'shipping': order['shipping'] ?? 0,
        'discount': order['discount'] ?? 0,
        'tax': order['tax'] ?? 0,
        'cgst': order['cgst'] ?? 0,
        'sgst': order['sgst'] ?? 0,
        'persontype': order['persontype'] ?? order['personType'],
        'doctorName': order['doctorName'],
        'userDetails': order['userDetails'],
      };

      final List<dynamic> items = order['items'] ?? [];
      for (var item in items) {
        final Map<String, dynamic> merged = {
          'orderId': orderId,
          'orderRef': orderRef,
          'orderStatus': orderStatus,
          'paymentStatus': paymentStatus,
          'bookingType': bookingType,
          'createdAt': createdAt.toIso8601String(),
          'orderItemId': orderRef,
          'quantity': item['quantity'] ?? 0,
          'type': item['type']?.toString() ?? '',
          'price': item['productSnapshot']?['price'] ?? 0,
          'discountPrice': item['productSnapshot']?['discountprice'] ?? 0,
          'totalPrice': (() {
            final orderBilling = order['billingSummary'] ?? {};
            final itemBilling = item['billingSummary'] ?? {};
            if (orderBilling['unitPrice'] != null &&
                orderBilling['unitPrice'] != 0) {
              return orderBilling['unitPrice'];
            }
            if (itemBilling['unitPrice'] != null &&
                itemBilling['unitPrice'] != 0) {
              return itemBilling['unitPrice'];
            }
            return order['total'] ?? 0;
          })(),
          'billingSummary': order['billingSummary'] ?? item['billingSummary'],
          'productId': item['productSnapshot']?['productId']?.toString() ?? '',
          'productDetails': item['productSnapshot'] ?? {},
          'orderDetails': orderDetailsJson,
          'userDetails': order['userDetails'],
          'shippingAddressDetails': order['shippingAddressDetails'],
          'billingAddressDetails': order['billingAddressDetails'],
        };
        flattenedItems.add(merged);
      }
    }
    return OrdersListModel(
      orderItems:
          flattenedItems.map((e) => OrderItemModel.fromJson(e)).toList(),
      pagination:
          PaginationModel.fromJson(json['pagination'] ?? <String, dynamic>{}),
    );
  }
}
