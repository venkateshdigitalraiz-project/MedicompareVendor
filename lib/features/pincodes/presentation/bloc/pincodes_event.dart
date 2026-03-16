abstract class PincodesEvent {}

class GetPincodesEvent extends PincodesEvent {}

class CreatePincodeEvent extends PincodesEvent {
  final String pincode;
  final String estimatedDelivery;
  final String status;

  CreatePincodeEvent({
    required this.pincode,
    required this.estimatedDelivery,
    required this.status,
  });
}

class UpdatePincodeEvent extends PincodesEvent {
  final String id;
  final String pincode;
  final String estimatedDelivery;
  final String status;

  UpdatePincodeEvent({
    required this.id,
    required this.pincode,
    required this.estimatedDelivery,
    required this.status,
  });
}

class DeletePincodeEvent extends PincodesEvent {
  final String id;

  DeletePincodeEvent({required this.id});
}
