import 'package:equatable/equatable.dart';

class CreateDeliverymanEntity extends Equatable {
  final String? id;

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
  final String? profileImage;

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
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.profileImage,
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

  factory CreateDeliverymanEntity.fromJson(Map<String, dynamic> rawJson) {
    // 1. Multi-level unwrapping for wrappers: data, deliveryMans, deliveryman, deliveryMan, driver, result, details, item
    Map<String, dynamic> json = Map<String, dynamic>.from(rawJson);

    for (int i = 0; i < 4; i++) {
      if (json['data'] is Map) {
        json = Map<String, dynamic>.from(json['data'] as Map);
      } else if (json['data'] is List &&
          (json['data'] as List).isNotEmpty &&
          (json['data'] as List).first is Map) {
        json = Map<String, dynamic>.from((json['data'] as List).first as Map);
      } else if (json['deliveryMans'] is Map) {
        json = Map<String, dynamic>.from(json['deliveryMans'] as Map);
      } else if (json['deliveryman'] is Map) {
        json = Map<String, dynamic>.from(json['deliveryman'] as Map);
      } else if (json['deliveryMan'] is Map) {
        json = Map<String, dynamic>.from(json['deliveryMan'] as Map);
      } else if (json['deliverymen'] is Map) {
        json = Map<String, dynamic>.from(json['deliverymen'] as Map);
      } else if (json['driver'] is Map) {
        json = Map<String, dynamic>.from(json['driver'] as Map);
      } else if (json['result'] is Map) {
        json = Map<String, dynamic>.from(json['result'] as Map);
      } else if (json['details'] is Map) {
        json = Map<String, dynamic>.from(json['details'] as Map);
      } else if (json['item'] is Map) {
        json = Map<String, dynamic>.from(json['item'] as Map);
      }
    }

    // Sub-maps
    Map<String, dynamic>? userMap = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : (json['userDetails'] is Map
            ? Map<String, dynamic>.from(json['userDetails'] as Map)
            : (json['profile'] is Map
                ? Map<String, dynamic>.from(json['profile'] as Map)
                : null));

    Map<String, dynamic>? personalMap = json['personalDetails'] is Map
        ? Map<String, dynamic>.from(json['personalDetails'] as Map)
        : (json['personal_details'] is Map
            ? Map<String, dynamic>.from(json['personal_details'] as Map)
            : (json['personal'] is Map
                ? Map<String, dynamic>.from(json['personal'] as Map)
                : null));

    Map<String, dynamic>? bankMap = json['bankDetails'] is Map
        ? Map<String, dynamic>.from(json['bankDetails'] as Map)
        : (json['bank_details'] is Map
            ? Map<String, dynamic>.from(json['bank_details'] as Map)
            : (json['bank'] is Map
                ? Map<String, dynamic>.from(json['bank'] as Map)
                : null));

    Map<String, dynamic>? vehicleMap = json['vehicleDetails'] is Map
        ? Map<String, dynamic>.from(json['vehicleDetails'] as Map)
        : (json['vehicle_details'] is Map
            ? Map<String, dynamic>.from(json['vehicle_details'] as Map)
            : (json['vehicle'] is Map
                ? Map<String, dynamic>.from(json['vehicle'] as Map)
                : null));

    Map<String, dynamic>? docsMap = json['proof'] is Map
        ? Map<String, dynamic>.from(json['proof'] as Map)
        : (json['documents'] is Map
            ? Map<String, dynamic>.from(json['documents'] as Map)
            : (json['proofDocuments'] is Map
                ? Map<String, dynamic>.from(json['proofDocuments'] as Map)
                : (json['proof_documents'] is Map
                    ? Map<String, dynamic>.from(json['proof_documents'] as Map)
                    : (json['proofs'] is Map
                        ? Map<String, dynamic>.from(json['proofs'] as Map)
                        : (json['kyc'] is Map
                            ? Map<String, dynamic>.from(json['kyc'] as Map)
                            : null)))));

    Map<String, dynamic>? emergencyMap = json['emergencyContact'] is Map
        ? Map<String, dynamic>.from(json['emergencyContact'] as Map)
        : (json['emergency_contact'] is Map
            ? Map<String, dynamic>.from(json['emergency_contact'] as Map)
            : (json['emergency'] is Map
                ? Map<String, dynamic>.from(json['emergency'] as Map)
                : null));

    Map<String, dynamic>? addressMap = json['addressDetails'] is Map
        ? Map<String, dynamic>.from(json['addressDetails'] as Map)
        : (json['address_details'] is Map
            ? Map<String, dynamic>.from(json['address_details'] as Map)
            : null);

    Map<String, dynamic>? settingsMap = json['settings'] is Map
        ? Map<String, dynamic>.from(json['settings'] as Map)
        : (json['operationalSettings'] is Map
            ? Map<String, dynamic>.from(json['operationalSettings'] as Map)
            : (json['operational_settings'] is Map
                ? Map<String, dynamic>.from(json['operational_settings'] as Map)
                : null));

    Map<String, dynamic>? workMap = json['workDetails'] is Map
        ? Map<String, dynamic>.from(json['workDetails'] as Map)
        : (json['work_details'] is Map
            ? Map<String, dynamic>.from(json['work_details'] as Map)
            : (json['work'] is Map
                ? Map<String, dynamic>.from(json['work'] as Map)
                : null));

    Map<String, dynamic>? hoursMap = json['workingHours'] is Map
        ? Map<String, dynamic>.from(json['workingHours'] as Map)
        : (workMap != null && workMap['workingHours'] is Map
            ? Map<String, dynamic>.from(workMap['workingHours'] as Map)
            : null);

    // ID
    final id = (json['_id'] ??
            json['id'] ??
            json['deliverymanId'] ??
            json['deliveryManId'] ??
            userMap?['_id'] ??
            userMap?['id'])
        ?.toString();

    // 1. Personal Details
    String fullName = json['name']?.toString() ??
        json['fullName']?.toString() ??
        json['deliveryManName']?.toString() ??
        json['deliverymanName']?.toString() ??
        json['driverName']?.toString() ??
        json['userName']?.toString() ??
        json['username']?.toString() ??
        userMap?['fullName']?.toString() ??
        userMap?['name']?.toString() ??
        userMap?['userName']?.toString() ??
        userMap?['username']?.toString() ??
        personalMap?['fullName']?.toString() ??
        personalMap?['name']?.toString() ??
        '';

    if (fullName.isEmpty) {
      final fName = json['firstName']?.toString() ??
          json['first_name']?.toString() ??
          userMap?['firstName']?.toString() ??
          userMap?['first_name']?.toString() ??
          personalMap?['firstName']?.toString() ??
          '';
      final lName = json['lastName']?.toString() ??
          json['last_name']?.toString() ??
          userMap?['lastName']?.toString() ??
          userMap?['last_name']?.toString() ??
          personalMap?['lastName']?.toString() ??
          '';
      if (fName.isNotEmpty || lName.isNotEmpty) {
        fullName = '$fName $lName'.trim();
      }
    }

    final email = json['email']?.toString() ??
        json['emailAddress']?.toString() ??
        userMap?['email']?.toString() ??
        personalMap?['email']?.toString() ??
        '';

    final phone = json['phone']?.toString() ??
        json['mobile']?.toString() ??
        json['phoneNumber']?.toString() ??
        json['contactNumber']?.toString() ??
        json['mobileNumber']?.toString() ??
        json['contactNo']?.toString() ??
        json['phoneNo']?.toString() ??
        userMap?['phone']?.toString() ??
        userMap?['mobile']?.toString() ??
        userMap?['phoneNumber']?.toString() ??
        userMap?['contactNumber']?.toString() ??
        personalMap?['phone']?.toString() ??
        personalMap?['mobile']?.toString() ??
        '';

    String dob = json['dateOfBirth']?.toString() ??
        json['dob']?.toString() ??
        json['date_of_birth']?.toString() ??
        userMap?['dob']?.toString() ??
        userMap?['dateOfBirth']?.toString() ??
        personalMap?['dob']?.toString() ??
        personalMap?['dateOfBirth']?.toString() ??
        '';
    if (dob.contains('T')) {
      dob = dob.split('T').first;
    }

    String gender = json['gender']?.toString() ??
        userMap?['gender']?.toString() ??
        personalMap?['gender']?.toString() ??
        'male';

    final address = json['address']?.toString() ??
        json['fullAddress']?.toString() ??
        json['addressLine1']?.toString() ??
        json['street']?.toString() ??
        userMap?['address']?.toString() ??
        userMap?['fullAddress']?.toString() ??
        personalMap?['address']?.toString() ??
        addressMap?['address']?.toString() ??
        addressMap?['fullAddress']?.toString() ??
        '';

    final city = json['city']?.toString() ??
        userMap?['city']?.toString() ??
        personalMap?['city']?.toString() ??
        addressMap?['city']?.toString() ??
        json['district']?.toString() ??
        '';

    final state = json['state']?.toString() ??
        userMap?['state']?.toString() ??
        personalMap?['state']?.toString() ??
        addressMap?['state']?.toString() ??
        json['province']?.toString() ??
        '';

    final pincode = json['pincode']?.toString() ??
        json['pinCode']?.toString() ??
        json['zipCode']?.toString() ??
        json['zip']?.toString() ??
        json['postalCode']?.toString() ??
        userMap?['pincode']?.toString() ??
        userMap?['pinCode']?.toString() ??
        personalMap?['pincode']?.toString() ??
        addressMap?['pincode']?.toString() ??
        addressMap?['pinCode']?.toString() ??
        '';

    final profileImage = json['profileImage']?.toString() ??
        json['profile_image']?.toString() ??
        json['image']?.toString() ??
        json['avatar']?.toString() ??
        json['photo']?.toString() ??
        userMap?['profileImage']?.toString() ??
        userMap?['image']?.toString() ??
        userMap?['avatar']?.toString();

    // 2. Work & Vehicle Details
    String vehicleType = json['vehicleType']?.toString() ??
        json['vehicle_type']?.toString() ??
        json['vehicle']?.toString() ??
        vehicleMap?['vehicleType']?.toString() ??
        vehicleMap?['vehicle_type']?.toString() ??
        vehicleMap?['type']?.toString() ??
        workMap?['vehicleType']?.toString() ??
        'Bike';

    final vehicleNumber = json['vehicleNumber']?.toString() ??
        json['vehicle_number']?.toString() ??
        json['vehicleNo']?.toString() ??
        json['vehicle_no']?.toString() ??
        json['registrationNumber']?.toString() ??
        json['regNumber']?.toString() ??
        vehicleMap?['vehicleNumber']?.toString() ??
        vehicleMap?['vehicleNo']?.toString() ??
        vehicleMap?['registrationNumber']?.toString() ??
        workMap?['vehicleNumber']?.toString() ??
        '';

    final drivingLicenseNumber = json['drivingLicense']?.toString() ??
        json['drivingLicenseNumber']?.toString() ??
        json['driving_license']?.toString() ??
        json['driving_license_number']?.toString() ??
        json['drivingLicenseNo']?.toString() ??
        json['licenseNumber']?.toString() ??
        json['license_number']?.toString() ??
        json['dlNumber']?.toString() ??
        json['dlNo']?.toString() ??
        vehicleMap?['drivingLicense']?.toString() ??
        vehicleMap?['drivingLicenseNumber']?.toString() ??
        docsMap?['drivingLicense']?.toString() ??
        docsMap?['drivingLicenseNumber']?.toString() ??
        docsMap?['licenseNumber']?.toString() ??
        workMap?['drivingLicense']?.toString() ??
        workMap?['drivingLicenseNumber']?.toString() ??
        '';

    final shiftStartTime = hoursMap?['start']?.toString() ??
        json['shiftStartTime']?.toString() ??
        json['shift_start_time']?.toString() ??
        json['shiftStart']?.toString() ??
        json['startTime']?.toString() ??
        json['start_time']?.toString() ??
        workMap?['shiftStartTime']?.toString() ??
        workMap?['startTime']?.toString() ??
        '09:00 AM';

    final shiftEndTime = hoursMap?['end']?.toString() ??
        json['shiftEndTime']?.toString() ??
        json['shift_end_time']?.toString() ??
        json['shiftEnd']?.toString() ??
        json['endTime']?.toString() ??
        json['end_time']?.toString() ??
        workMap?['shiftEndTime']?.toString() ??
        workMap?['endTime']?.toString() ??
        '06:00 PM';

    // 3. Bank Details
    final bankName = bankMap?['bankName']?.toString() ??
        bankMap?['bank_name']?.toString() ??
        bankMap?['name']?.toString() ??
        json['bankName']?.toString() ??
        json['bank_name']?.toString() ??
        json['bank']?.toString() ??
        '';

    final accountNumber = bankMap?['accountNumber']?.toString() ??
        bankMap?['account_number']?.toString() ??
        bankMap?['accNo']?.toString() ??
        bankMap?['accountNo']?.toString() ??
        json['accountNumber']?.toString() ??
        json['account_number']?.toString() ??
        json['accNo']?.toString() ??
        json['accountNo']?.toString() ??
        '';

    final accountHolderName = bankMap?['accountHolderName']?.toString() ??
        bankMap?['account_holder_name']?.toString() ??
        bankMap?['holderName']?.toString() ??
        bankMap?['accountName']?.toString() ??
        json['accountHolderName']?.toString() ??
        json['account_holder_name']?.toString() ??
        json['holderName']?.toString() ??
        json['accountName']?.toString() ??
        '';

    final ifscCode = bankMap?['ifscCode']?.toString() ??
        bankMap?['ifsc_code']?.toString() ??
        bankMap?['ifsc']?.toString() ??
        json['ifscCode']?.toString() ??
        json['ifsc_code']?.toString() ??
        json['ifsc']?.toString() ??
        '';

    final branchName = bankMap?['branchName']?.toString() ??
        bankMap?['branch_name']?.toString() ??
        bankMap?['branch']?.toString() ??
        json['branchName']?.toString() ??
        json['branch_name']?.toString() ??
        json['branch']?.toString() ??
        '';

    // 4. Proof Documents
    final aadhaarNumber = docsMap?['aadhaarNumber']?.toString() ??
        docsMap?['aadhaar_number']?.toString() ??
        docsMap?['aadharNumber']?.toString() ??
        docsMap?['aadhar_number']?.toString() ??
        docsMap?['aadhaarNo']?.toString() ??
        json['aadhaarNumber']?.toString() ??
        json['aadhaar_number']?.toString() ??
        json['aadharNumber']?.toString() ??
        '';

    final panNumber = docsMap?['panNumber']?.toString() ??
        docsMap?['pan_number']?.toString() ??
        docsMap?['panNo']?.toString() ??
        docsMap?['pan']?.toString() ??
        json['panNumber']?.toString() ??
        json['pan_number']?.toString() ??
        json['panNo']?.toString() ??
        '';

    final aadhaarDoc = docsMap?['aadhaarFile']?.toString() ??
        docsMap?['aadhaarDoc']?.toString() ??
        docsMap?['aadhaarImage']?.toString() ??
        docsMap?['aadharImage']?.toString() ??
        docsMap?['aadhaarUrl']?.toString() ??
        docsMap?['aadhaar_url']?.toString() ??
        docsMap?['aadhaar']?.toString() ??
        docsMap?['aadhaar_doc']?.toString() ??
        json['aadhaarFile']?.toString() ??
        json['aadhaarDoc']?.toString() ??
        json['aadhaarImage']?.toString() ??
        json['aadhaarUrl']?.toString();

    final panDoc = docsMap?['panFile']?.toString() ??
        docsMap?['panDoc']?.toString() ??
        docsMap?['panImage']?.toString() ??
        docsMap?['panUrl']?.toString() ??
        docsMap?['pan_url']?.toString() ??
        docsMap?['pan']?.toString() ??
        docsMap?['pan_doc']?.toString() ??
        json['panFile']?.toString() ??
        json['panDoc']?.toString() ??
        json['panImage']?.toString() ??
        json['panUrl']?.toString();

    final bikeRcDoc = docsMap?['bikeRcFile']?.toString() ??
        docsMap?['bikeRcDoc']?.toString() ??
        docsMap?['rcFile']?.toString() ??
        docsMap?['rcDoc']?.toString() ??
        docsMap?['rcImage']?.toString() ??
        docsMap?['rcUrl']?.toString() ??
        docsMap?['rc_doc']?.toString() ??
        docsMap?['rc_url']?.toString() ??
        docsMap?['rc']?.toString() ??
        vehicleMap?['bikeRcFile']?.toString() ??
        vehicleMap?['rcDoc']?.toString() ??
        vehicleMap?['rcImage']?.toString() ??
        json['bikeRcFile']?.toString() ??
        json['bikeRcDoc']?.toString() ??
        json['rcDoc']?.toString() ??
        json['rcImage']?.toString();

    final drivingLicenseDoc = docsMap?['drivingLicenseFile']?.toString() ??
        docsMap?['drivingLicenseDoc']?.toString() ??
        docsMap?['licenseFile']?.toString() ??
        docsMap?['licenseDoc']?.toString() ??
        docsMap?['licenseImage']?.toString() ??
        docsMap?['licenseUrl']?.toString() ??
        docsMap?['dlDoc']?.toString() ??
        docsMap?['dlImage']?.toString() ??
        docsMap?['license']?.toString() ??
        vehicleMap?['drivingLicenseFile']?.toString() ??
        vehicleMap?['drivingLicenseDoc']?.toString() ??
        json['drivingLicenseFile']?.toString() ??
        json['drivingLicenseDoc']?.toString() ??
        json['licenseDoc']?.toString();

    // 5. Settings
    final status = json['status']?.toString() ??
        userMap?['status']?.toString() ??
        settingsMap?['status']?.toString() ??
        'active';

    final autoAssign = json['autoAcceptOrders'] == true ||
        workMap?['autoAcceptOrders'] == true ||
        json['autoAssign'] == true ||
        json['auto_assign'] == true ||
        json['autoAssign'] == 'true' ||
        json['auto_assignment'] == true ||
        settingsMap?['autoAssign'] == true ||
        settingsMap?['auto_assign'] == true ||
        settingsMap?['autoAcceptOrders'] == true;

    final maxDailyOrders = int.tryParse(
            (json['maxDailyOrders'] ??
                    json['max_daily_orders'] ??
                    json['maxOrders'] ??
                    json['dailyLimit'] ??
                    settingsMap?['maxDailyOrders'] ??
                    settingsMap?['max_daily_orders'] ??
                    20)
                .toString()) ??
        20;

    final emergencyContactName = json['emergencyContactName']?.toString() ??
        json['emergency_contact_name']?.toString() ??
        json['emergencyName']?.toString() ??
        emergencyMap?['name']?.toString() ??
        emergencyMap?['contactName']?.toString() ??
        emergencyMap?['fullName']?.toString();

    final emergencyContactPhone = json['emergencyContactPhone']?.toString() ??
        json['emergency_contact_phone']?.toString() ??
        json['emergencyPhone']?.toString() ??
        emergencyMap?['phone']?.toString() ??
        emergencyMap?['mobile']?.toString() ??
        emergencyMap?['contactPhone']?.toString();

    final notes = json['notes']?.toString() ??
        json['instructions']?.toString() ??
        json['remark']?.toString() ??
        json['remarks']?.toString() ??
        json['description']?.toString() ??
        settingsMap?['notes']?.toString();

    return CreateDeliverymanEntity(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      dob: dob,
      gender: gender,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      profileImage: profileImage,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      drivingLicenseNumber: drivingLicenseNumber,
      shiftStartTime: shiftStartTime,
      shiftEndTime: shiftEndTime,
      bankName: bankName,
      accountNumber: accountNumber,
      accountHolderName: accountHolderName,
      ifscCode: ifscCode,
      branchName: branchName,
      aadhaarNumber: aadhaarNumber,
      panNumber: panNumber,
      aadhaarDoc: aadhaarDoc,
      panDoc: panDoc,
      bikeRcDoc: bikeRcDoc,
      drivingLicenseDoc: drivingLicenseDoc,
      status: status,
      autoAssign: autoAssign,
      maxDailyOrders: maxDailyOrders,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      notes: notes,
    );
  }

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
      'vehicleType': vehicleType.toLowerCase(),
      'vehicleNumber': vehicleNumber,
      'vehicleNo': vehicleNumber,
      'drivingLicense': drivingLicenseNumber,
      'drivingLicenseNumber': drivingLicenseNumber,
      'licenseNumber': drivingLicenseNumber,
      'shiftStartTime': shiftStartTime,
      'shiftEndTime': shiftEndTime,
      'workingHours': {
        'start': shiftStartTime,
        'end': shiftEndTime,
      },
      'bankDetails': {
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountHolderName': accountHolderName,
        'ifscCode': ifscCode,
        'branchName': branchName,
      },
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'ifscCode': ifscCode,
      'branchName': branchName,
      'proof': {
        'aadhaarNumber': aadhaarNumber,
        'panNumber': panNumber,
        if (aadhaarDoc != null && aadhaarDoc!.isNotEmpty)
          'aadhaarFile': aadhaarDoc,
        if (panDoc != null && panDoc!.isNotEmpty) 'panFile': panDoc,
        if (bikeRcDoc != null && bikeRcDoc!.isNotEmpty)
          'bikeRcFile': bikeRcDoc,
        if (drivingLicenseDoc != null && drivingLicenseDoc!.isNotEmpty)
          'drivingLicenseFile': drivingLicenseDoc,
      },
      'aadhaarNumber': aadhaarNumber,
      'panNumber': panNumber,
      'aadhaarFile': aadhaarDoc,
      'panFile': panDoc,
      'bikeRcFile': bikeRcDoc,
      'drivingLicenseFile': drivingLicenseDoc,
      'aadhaarDoc': aadhaarDoc,
      'panDoc': panDoc,
      'bikeRcDoc': bikeRcDoc,
      'drivingLicenseDoc': drivingLicenseDoc,
      'status': status.toLowerCase(),
      'autoAssign': autoAssign,
      'autoAcceptOrders': autoAssign,
      'workDetails': {
        'workingHours': {
          'start': shiftStartTime,
          'end': shiftEndTime,
        },
        'autoAcceptOrders': autoAssign,
      },
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
        id,
        fullName,
        email,
        phone,
        dob,
        gender,
        address,
        city,
        state,
        pincode,
        profileImage,
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
