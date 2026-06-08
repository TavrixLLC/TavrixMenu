import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Subscription screen placeholder', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
