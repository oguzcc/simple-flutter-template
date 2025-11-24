import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:daisy/router/screens.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sign In Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to home for now
                context.goNamed(Screens.home.name);
              },
              child: const Text('Continue to Home'),
            ),
          ],
        ),
      ),
    );
  }
}