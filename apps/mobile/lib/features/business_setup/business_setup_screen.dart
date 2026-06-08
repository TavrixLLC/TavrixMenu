import 'package:flutter/material.dart';

class BusinessSetupScreen extends StatelessWidget {
  const BusinessSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business setup')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Business profile setup placeholder', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
