import 'package:MediCompare/core/utils/token_storage.dart';
import 'package:MediCompare/features/vendor_profile/presentation/providers/vendor_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../../features/dashboard/presentation/bloc/dashboard_event.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool rememberMe = false;
  bool isPasswordVisible = false;
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await TokenStorage.getSavedCredentials();
    if (credentials['rememberMe'] == true) {
      setState(() {
        rememberMe = true;
        emailController.text = credentials['email'] ?? '';
        passwordController.text = credentials['password'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) async {
            if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            } else if (state is LoginSuccess) {
              final vendor = state.vendor;
              await TokenStorage.saveCredentials(
                emailController.text.trim(),
                passwordController.text,
                rememberMe,
              );

              if (!context.mounted) return;
              Provider.of<VendorProfileProvider>(context, listen: false)
                  .setVendor(vendor);
              await TokenStorage.saveToken(vendor.token);
              await TokenStorage.saveVendorId(vendor.id);

              if (!context.mounted) return;
              context.read<DashboardBloc>().add(GetDashboardEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login successful!')),
              );
              context.go('/bottom-nav');
            }
          },
          builder: (context, state) {
            final isLoading = state is LoginLoading;
            final isOtpRequired = state is LoginOtpRequired ||
                (state is LoginFailure && state.returnToOtp);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// LOGO
                Image.asset(
                  'assets/medi_compare_logo.png',
                  width: 200,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                Text(
                  "Sign in to Your Account",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 48),

                /// EMAIL
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email Address",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _inputField(
                  hint: "Enter your email",
                  controller: emailController,
                ),

                const SizedBox(height: 24),

                /// PASSWORD
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _passwordField(controller: passwordController),

                const SizedBox(height: 12),

                /// REMEMBER + FORGOT
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() => rememberMe = value!);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        activeColor: const Color(0xFF8046F1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Remember me",
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: const Color(0xFF64748B)),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8046F1),
                        ),
                      ),
                    ),
                  ],
                ),

                if (isOtpRequired) ...[
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "OTP",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _OtpInput(
                    controller: otpController,
                  ),
                ],

                const SizedBox(height: 40),

                /// LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8046F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            if (isOtpRequired) {
                              context.read<LoginBloc>().add(VerifyOtpEvent(
                                    email: emailController.text.trim(),
                                    password: passwordController.text,
                                    otp: otpController.text.trim(),
                                  ));
                            } else {
                              context.read<LoginBloc>().add(SubmitLoginEvent(
                                    email: emailController.text.trim(),
                                    password: passwordController.text,
                                  ));
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isOtpRequired ? "Verify & Sign in" : "Log In",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

            /// REGISTER
            /*
            RichText(
              text: TextSpan(
                text: "Want to become a member? ",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
                children: [
                  TextSpan(
                    text: "Create an account.",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF8046F1),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        context.push(
                          '/registration-webview',
                          extra: 'https://vendor.medicompares.com/register',
                        );
                      },
                  ),
                ],
              ),
            ),
            */
            const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _inputField({
    required String hint,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF94A3B8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8046F1), width: 1.5),
        ),
      ),
    );
  }

  Widget _passwordField({required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: !isPasswordVisible,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: "Enter your password",
        hintStyle:
            GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF94A3B8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            size: 20,
            color: const Color(0xFF94A3B8),
          ),
          onPressed: () =>
              setState(() => isPasswordVisible = !isPasswordVisible),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8046F1), width: 1.5),
        ),
      ),
    );
  }
}

class _OtpInput extends StatefulWidget {
  final TextEditingController controller;
  const _OtpInput({required this.controller});

  @override
  State<_OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<_OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (index) => TextEditingController());
    _focusNodes = List.generate(4, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _updateMainController() {
    widget.controller.text = _controllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 60,
          height: 60,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8046F1), width: 1.5),
              ),
            ),
            onChanged: (value) {
              _updateMainController();
              if (value.isNotEmpty && index < 3) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}

