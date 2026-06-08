import 'package:flutter/material.dart';

class StaffScannerScreen extends StatelessWidget {
  const StaffScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff scanner')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Staff scanner placeholder', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
