import 'package:equatable/equatable.dart';

class CreateDeliverymanEntity extends Equatable {
  // 1. Personal Details
  final String fullName;
  final String email;
  final String phone;
  final String dob;
  final String gender;
  final String address;
  final String city;
  final String state;
  final String pincode;

  // 2. Work Details
  final String vehicleType;
  final String vehicleNumber;
  final String drivingLicenseNumber;
  final String shiftStartTime;
  final String shiftEndTime;

  // 3. Bank Details
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String ifscCode;
  final String branchName;

  // 4. Proof Documents
  final String aadhaarNumber;
  final String panNumber;
  final String? aadhaarDoc;
  final String? panDoc;
  final String? bikeRcDoc;
  final String? drivingLicenseDoc;

  // 5. Settings
  final String status;
  final bool autoAssign;
  final int maxDailyOrders;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? notes;

  const CreateDeliverymanEntity({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.drivingLicenseNumber,
    this.shiftStartTime = '09:00 AM',
    this.shiftEndTime = '06:00 PM',
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.ifscCode,
    this.branchName = '',
    required this.aadhaarNumber,
    required this.panNumber,
    this.aadhaarDoc,
    this.panDoc,
    this.bikeRcDoc,
    this.drivingLicenseDoc,
    this.status = 'active',
    this.autoAssign = true,
    this.maxDailyOrders = 20,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'name': fullName,
      'email': email,
      'phone': phone,
      'mobile': phone,
      'dob': dob,
      'dateOfBirth': dob,
      'gender': gender.toLowerCase(),
      'address': address,
      'fullAddress': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'vehicleNo': vehicleNumber,
      'drivingLicenseNumber': drivingLicenseNumber,
      'licenseNumber': drivingLicenseNumber,
      'shiftStartTime': shiftStartTime,
      'shiftEndTime': shiftEndTime,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'ifscCode': ifscCode,
      'branchName': branchName,
      'aadhaarNumber': aadhaarNumber,
      'panNumber': panNumber,
      'aadhaarDoc': aadhaarDoc,
      'panDoc': panDoc,
      'bikeRcDoc': bikeRcDoc,
      'drivingLicenseDoc': drivingLicenseDoc,
      'status': status.toLowerCase(),
      'autoAssign': autoAssign,
      'maxDailyOrders': maxDailyOrders,
      if (emergencyContactName != null && emergencyContactName!.isNotEmpty)
        'emergencyContactName': emergencyContactName,
      if (emergencyContactPhone != null && emergencyContactPhone!.isNotEmpty)
        'emergencyContactPhone': emergencyContactPhone,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
        fullName,
        email,
        phone,
        dob,
        gender,
        address,
        city,
        state,
        pincode,
        vehicleType,
        vehicleNumber,
        drivingLicenseNumber,
        shiftStartTime,
        shiftEndTime,
        bankName,
        accountNumber,
        accountHolderName,
        ifscCode,
        branchName,
        aadhaarNumber,
        panNumber,
        aadhaarDoc,
        panDoc,
        bikeRcDoc,
        drivingLicenseDoc,
        status,
        autoAssign,
        maxDailyOrders,
        emergencyContactName,
        emergencyContactPhone,
        notes,
      ];
}
