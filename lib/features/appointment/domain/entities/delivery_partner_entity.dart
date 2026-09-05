import 'package:equatable/equatable.dart';

class DeliveryPartnerEntity extends Equatable {
  final String id;
  final String partnerId;
  final String name;
  final String phone;
  final String email;
  final String vehicleNumber;
  final double rating;
  final String status;
  final String? profileImage;
  final String deliveryManType;

  const DeliveryPartnerEntity({
    required this.id,
    required this.partnerId,
    required this.name,
    required this.phone,
    this.email = '',
    this.vehicleNumber = '',
    this.rating = 0.0,
    this.status = 'active',
    this.profileImage,
    this.deliveryManType = 'admin',
  });

  @override
  List<Object?> get props => [
        id,
        partnerId,
        name,
        phone,
        email,
        vehicleNumber,
        rating,
        status,
        profileImage,
        deliveryManType,
      ];
}

class DeliveryPartnersResultEntity extends Equatable {
  final List<DeliveryPartnerEntity> deliveryMans;
  final DeliveryPartnerEntity? ownDeliveryUser;

  const DeliveryPartnersResultEntity({
    this.deliveryMans = const [],
    this.ownDeliveryUser,
  });

  @override
  List<Object?> get props => [deliveryMans, ownDeliveryUser];
}
