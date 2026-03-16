import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/core/utils/token_storage.dart';
import 'package:MediCompare/features/auth/auth_injection.dart';
import 'package:MediCompare/features/vendor_profile/presentation/providers/vendor_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
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
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (mounted) {
        // Sync vendor to VendorProfileProvider
        Provider.of<VendorProfileProvider>(context, listen: false).setVendor(vendor);

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 110),

            /// LOGO
            SizedBox(
              width: 191,
              height: 72,
              child: Image.asset(
                'assets/medi_compare_logo.png',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 12),

            /// TITLE
            Text(
              "Sign in to Your Account",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 33),

            /// EMAIL
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Email Address",
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
            const SizedBox(height: 6),
            _inputField(
              hint: "Enter Your email",
              controller: emailController,
            ),

            const SizedBox(height: 16),

            /// PASSWORD
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Password",
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
            const SizedBox(height: 6),
            _passwordField(controller: passwordController),

            const SizedBox(height: 10),

            /// REMEMBER + FORGOT
            Row(
              children: [
                SizedBox(
                  height: 18,
                  width: 18,
                  child: Checkbox(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() => rememberMe = value!);
                    },
                    activeColor: AppColors.primary,
                    checkColor: AppColors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "Remember me",
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context.push('/forgot-password');
                  },
                  child: Text(
                    "Forgot Password?",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF8046F1),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 128),

            /// LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoading ? null : _handleLogin,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Log In",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 22),

            // /// REGISTER
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text(
            //       "New Vendor? ",
            //       style: GoogleFonts.poppins(fontSize: 12),
            //     ),
            //     TextButton(
            //       onPressed: () {
            //         context.push('/register');
            //       },
            //       child: Text(
            //         "Register Here",
            //         style: GoogleFonts.poppins(
            //           fontSize: 12,
            //           color: AppColors.primary,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// EMAIL FIELD
  static Widget _inputField({
    required String hint,
    required TextEditingController controller,
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  /// PASSWORD FIELD
  Widget _passwordField({required TextEditingController controller}) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        obscureText: !isPasswordVisible,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Enter Your Password",
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              size: 18,
              color: AppColors.grey,
            ),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
