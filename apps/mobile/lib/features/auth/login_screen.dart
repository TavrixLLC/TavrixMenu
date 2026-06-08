import 'package:flutter/material.dart';

import '../../app/router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tavrix Menu',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Business user login',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text('For business owners, managers, and staff only.'),
              const SizedBox(height: 32),
              // Clerk Flutter SDK SignIn will replace this placeholder button.
              FilledButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard),
                child: const Text('Continue to dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
