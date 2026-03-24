import 'package:flutter/material.dart';

import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Better for scrollable forms
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: const LoginForm(),
      ),
    );
  }
}
