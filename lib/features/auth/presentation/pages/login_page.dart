import 'package:flutter/material.dart';
import 'dart:ui';

import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 237, 237, 237),
      resizeToAvoidBottomInset: false,
      body: LoginForm(),
    );
  }
}
