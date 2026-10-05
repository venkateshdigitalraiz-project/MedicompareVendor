import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../../domain/usecases/login_usecase.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc({required this.loginUseCase}) : super(LoginInitial()) {
    on<SubmitLoginEvent>(_onSubmitLogin);
    on<VerifyOtpEvent>(_onVerifyOtp);
  }

  Future<void> _onSubmitLogin(SubmitLoginEvent event, Emitter<LoginState> emit) async {
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(const LoginFailure(error: 'Please enter email and password'));
      return;
    }
    emit(LoginLoading());
    try {
      await loginUseCase.call(
        email: event.email,
        password: event.password,
      );
      // If it surprisingly returns user data without OTP, we still proceed to OTP or success?
      // Since UI expects OTP, emit OTP required anyway.
      emit(LoginOtpRequired(email: event.email, password: event.password));
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('OTP_SENT')) {
        emit(LoginOtpRequired(email: event.email, password: event.password));
      } else {
        if (errorMsg.startsWith('ServerException: ')) {
          errorMsg = errorMsg.substring('ServerException: '.length);
        } else if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.substring('Exception: '.length);
        } else if (errorMsg == 'UNAUTHORIZED_ACCESS_401') {
          errorMsg = 'Incorrect email/password';
        }
        emit(LoginFailure(error: errorMsg));
      }
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<LoginState> emit) async {
    if (event.otp.length < 4) {
      emit(const LoginFailure(error: 'Please enter a valid 4-digit OTP', returnToOtp: true));
      return;
    }
    
    emit(LoginLoading());
    try {
      final vendor = await loginUseCase.call(
        email: event.email,
        password: event.password,
        otp: event.otp,
        fcmToken: null,
      );
      emit(LoginSuccess(vendor: vendor));
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.startsWith('ServerException: ')) {
        errorMsg = errorMsg.substring('ServerException: '.length);
      } else if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring('Exception: '.length);
      } else if (errorMsg == 'UNAUTHORIZED_ACCESS_401') {
        errorMsg = 'Incorrect email/password';
      }
      emit(LoginFailure(error: errorMsg, returnToOtp: false));
    }
  }
}
