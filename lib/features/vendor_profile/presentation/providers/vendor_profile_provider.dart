import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../../auth/domain/entities/vendor_entity.dart';
import '../../domain/usecases/update_step_one_usecase.dart';
import '../../domain/usecases/update_step_two_usecase.dart';

class VendorProfileProvider extends ChangeNotifier {
  final UpdateStepOneUseCase updateStepOneUseCase;
  final UpdateStepTwoUseCase updateStepTwoUseCase;

  VendorProfileProvider({
    required this.updateStepOneUseCase,
    required this.updateStepTwoUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  VendorEntity? _vendor;
  VendorEntity? get vendor => _vendor;

  void setVendor(VendorEntity vendor) {
    _vendor = vendor;
    notifyListeners();
  }

  Future<bool> updateStepOne({
    required String proofType,
    required String idNumber,
    required XFile frontImage,
    required XFile backImage,
    required String residentialAddress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_vendor == null)
        throw Exception("Session expired. Please login again.");

      _vendor = await updateStepOneUseCase.call(
        token: _vendor!.token,
        proofType: proofType,
        idNumber: idNumber,
        frontImage: frontImage,
        backImage: backImage,
        residentialAddress: residentialAddress,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStepTwo({
    required String name,
    required String businessLegalName,
    required String email,
    required String mobile,
    String? altMobile,
    required String address,
    required double lat,
    required double lng,
    required List<String> categoryIds,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_vendor == null)
        throw Exception("Session expired. Please login again.");

      _vendor = await updateStepTwoUseCase.call(
        token: _vendor!.token,
        name: name,
        businessLegalName: businessLegalName,
        email: email,
        mobile: mobile,
        altMobile: altMobile,
        address: address,
        lat: lat,
        lng: lng,
        categoryIds: categoryIds,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
