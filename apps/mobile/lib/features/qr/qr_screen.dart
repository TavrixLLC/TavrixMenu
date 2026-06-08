import 'package:flutter/material.dart';

class QRScreen extends StatelessWidget {
  const QRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('QR menu screen placeholder', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
