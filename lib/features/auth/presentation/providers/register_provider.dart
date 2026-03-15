import 'package:flutter/material.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/entities/vendor_entity.dart';

class RegisterProvider extends ChangeNotifier {
  final RegisterUseCase registerUseCase;

  RegisterProvider({required this.registerUseCase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  VendorEntity? _vendor;
  VendorEntity? get vendor => _vendor;

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vendor = await registerUseCase.call(
        firstName: firstName,
        lastName: lastName,
        email: email,
        mobile: mobile,
        password: password,
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
