import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool rememberMe = false;
  bool isPasswordVisible = false;

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
            _inputField(hint: "Enter Your email"),

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
            _passwordField(),

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
                    activeColor: const Color(0xFF8B5CF6),
                    checkColor: Colors.white,
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
                  backgroundColor: const Color(0xFF7C4DFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  /// ✅ go_router navigation
                  context.go('/bottom-nav');
                },
                child: Text(
                  "Log In",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            /// REGISTER
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "New Vendor? ",
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/register');
                  },
                  child: Text(
                    "Register Here",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// EMAIL FIELD
  static Widget _inputField({required String hint}) {
    return SizedBox(
      height: 48,
      child: TextField(
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF9CA3AF),
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
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
          ),
        ),
      ),
    );
  }

  /// PASSWORD FIELD
  Widget _passwordField() {
    return SizedBox(
      height: 48,
      child: TextField(
        obscureText: !isPasswordVisible,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Enter Your Password",
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF9CA3AF),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              size: 18,
              color: Colors.grey,
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
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
          ),
        ),
      ),
    );
  }
}
