import 'package:equatable/equatable.dart';
import '../../domain/entities/vendor_entity.dart';

abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginOtpRequired extends LoginState {
  final String email;
  final String password;
  const LoginOtpRequired({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}
class LoginSuccess extends LoginState {
  final VendorEntity vendor;
  const LoginSuccess({required this.vendor});
  @override
  List<Object?> get props => [vendor];
}
class LoginFailure extends LoginState {
  final String error;
  final bool returnToOtp;
  const LoginFailure({required this.error, this.returnToOtp = false});
  @override
  List<Object?> get props => [error, returnToOtp];
}
