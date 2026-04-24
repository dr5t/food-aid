import 'package:flutter/material.dart';
import 'login_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We redirect to LoginScreen which now handles both login and signup
    // In a real app, you'd pass a parameter to select the 'Register' tab
    return const LoginScreen();
  }
}
