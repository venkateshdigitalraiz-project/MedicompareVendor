import 'package:MediCompare/core/utils/token_storage.dart';
import 'package:MediCompare/features/auth/auth_injection.dart';
import 'package:MediCompare/features/vendor_profile/presentation/providers/vendor_profile_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../../features/dashboard/presentation/bloc/dashboard_event.dart';

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

  final _loginUseCase = AuthInjection.provideLoginUseCase();

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
    super.dispose();
  }

  void _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final vendor = await _loginUseCase.call(
        email: email,
        password: password,
      );

      if (mounted) {
        // Handle Remember Me
        await TokenStorage.saveCredentials(email, password, rememberMe);

        // Sync vendor to VendorProfileProvider
        Provider.of<VendorProfileProvider>(context, listen: false)
            .setVendor(vendor);

        // Save token and vendor ID for persistence
        await TokenStorage.saveToken(vendor.token);
        await TokenStorage.saveVendorId(vendor.id);

        if (mounted) {
          // Refresh dashboard data with new token
          context.read<DashboardBloc>().add(GetDashboardEvent());

          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );

          // Directly navigate to bottom-nav (Home) as requested
          context.go('/bottom-nav');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
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
                onPressed: isLoading ? null : _handleLogin,
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
                        "Log In",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),

            /// REGISTER
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
                      ..onTap = () async {
                        final url = Uri.parse(
                            'https://vendor.medicompares.com/register');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
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
