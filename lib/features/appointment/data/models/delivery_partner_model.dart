import '../../domain/entities/delivery_partner_entity.dart';

class DeliveryPartnerModel extends DeliveryPartnerEntity {
  const DeliveryPartnerModel({
    required super.id,
    required super.partnerId,
    required super.name,
    required super.phone,
    super.email,
    super.vehicleNumber,
    super.rating,
    super.status,
    super.profileImage,
    super.deliveryManType,
  });

  factory DeliveryPartnerModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    // Partner ID (e.g. DP20260004 or custom display ID)
    final partnerId = json['deliveryPartnerId']?.toString() ??
        json['deliveryManId']?.toString() ??
        json['partnerId']?.toString() ??
        json['customId']?.toString() ??
        json['displayId']?.toString() ??
        (rawId.isNotEmpty ? (rawId.length > 8 ? rawId.substring(rawId.length - 8).toUpperCase() : rawId) : 'N/A');

    Map<String, dynamic>? userMap;
    if (json['user'] is Map) {
      userMap = Map<String, dynamic>.from(json['user'] as Map);
    } else if (json['userDetails'] is Map) {
      userMap = Map<String, dynamic>.from(json['userDetails'] as Map);
    } else if (json['deliveryMan'] is Map) {
      userMap = Map<String, dynamic>.from(json['deliveryMan'] as Map);
    } else if (json['deliveryman'] is Map) {
      userMap = Map<String, dynamic>.from(json['deliveryman'] as Map);
    }

    // Name
    String name = json['fullName']?.toString() ??
        json['name']?.toString() ??
        userMap?['fullName']?.toString() ??
        userMap?['name']?.toString() ??
        '';
    if (name.isEmpty && (json['firstName'] != null || json['lastName'] != null)) {
      name = '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
    }
    if (name.isEmpty && userMap != null && (userMap['firstName'] != null || userMap['lastName'] != null)) {
      name = '${userMap['firstName'] ?? ''} ${userMap['lastName'] ?? ''}'.trim();
    }
    if (name.isEmpty) {
      name = json['userName']?.toString() ?? json['username']?.toString() ?? userMap?['username']?.toString() ?? 'Delivery Partner';
    }

    // Phone / Mobile
    final phone = json['phone']?.toString() ??
        json['mobile']?.toString() ??
        json['phoneNumber']?.toString() ??
        json['contactNumber']?.toString() ??
        userMap?['phone']?.toString() ??
        userMap?['mobile']?.toString() ??
        '';

    // Email
    final email = json['email']?.toString() ?? userMap?['email']?.toString() ?? '';

    // Vehicle number
    String vehicleNumber = json['vehicleNumber']?.toString() ??
        json['vehicleNo']?.toString() ??
        '';
    if (vehicleNumber.isEmpty && json['vehicleDetails'] is Map) {
      final vMap = json['vehicleDetails'] as Map;
      vehicleNumber = vMap['vehicleNumber']?.toString() ??
          vMap['vehicleNo']?.toString() ??
          '';
    }
    if (vehicleNumber.isEmpty && userMap != null) {
      vehicleNumber = userMap['vehicleNumber']?.toString() ??
          userMap['vehicleNo']?.toString() ??
          '';
    }

    // Rating
    double rating = 0.0;
    if (json['rating'] != null) {
      rating = double.tryParse(json['rating'].toString()) ?? 0.0;
    } else if (json['avgRating'] != null) {
      rating = double.tryParse(json['avgRating'].toString()) ?? 0.0;
    } else if (json['averageRating'] != null) {
      rating = double.tryParse(json['averageRating'].toString()) ?? 0.0;
    } else if (json['ratings'] != null) {
      rating = double.tryParse(json['ratings'].toString()) ?? 0.0;
    }

    final status = json['status']?.toString() ?? userMap?['status']?.toString() ?? 'active';
    final profileImage = json['profileImage']?.toString() ??
        json['image']?.toString() ??
        userMap?['profileImage']?.toString() ??
        userMap?['image']?.toString();
    final deliveryManType = json['deliveryManType']?.toString() ?? 'admin';

    return DeliveryPartnerModel(
      id: rawId,
      partnerId: partnerId,
      name: name,
      phone: phone,
      email: email,
      vehicleNumber: vehicleNumber,
      rating: rating,
      status: status,
      profileImage: profileImage,
      deliveryManType: deliveryManType,
    );
  }

  factory DeliveryPartnerModel.fromUserJson(Map<String, dynamic> json) {
    final rawId = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final partnerId = json['vendorsId']?.toString() ??
        json['vendorId']?.toString() ??
        json['customId']?.toString() ??
        (rawId.isNotEmpty
            ? (rawId.length > 8
                ? rawId.substring(rawId.length - 8).toUpperCase()
                : rawId)
            : 'N/A');

    String name = '';
    if (json['firstName'] != null || json['lastName'] != null) {
      name = '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
    }
    if (name.isEmpty) {
      name = json['fullName']?.toString() ??
          json['name']?.toString() ??
          'Own Delivery Partner';
    }

    final phone = json['mobile']?.toString() ??
        json['phone']?.toString() ??
        json['phoneNumber']?.toString() ??
        '';

    final email = json['email']?.toString() ?? '';

    String? profileImage;
    if (json['profileImage'] is Map) {
      profileImage = json['profileImage']['url']?.toString();
    } else if (json['profileImage'] != null) {
      profileImage = json['profileImage'].toString();
    }

    final status = json['status']?.toString() ?? 'active';
    final deliveryManType = json['type']?.toString() ?? 'vendor';

    return DeliveryPartnerModel(
      id: rawId,
      partnerId: partnerId,
      name: name,
      phone: phone,
      email: email,
      vehicleNumber: '',
      rating: 5.0,
      status: status,
      profileImage: profileImage,
      deliveryManType: deliveryManType,
    );
  }
}

class DeliveryPartnersResultModel extends DeliveryPartnersResultEntity {
  const DeliveryPartnersResultModel({
    super.deliveryMans = const [],
    super.ownDeliveryUser,
  });
}
