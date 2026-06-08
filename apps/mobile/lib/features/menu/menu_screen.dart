import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Menu management placeholder', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
