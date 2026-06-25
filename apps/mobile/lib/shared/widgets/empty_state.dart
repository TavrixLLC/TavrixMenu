import 'package:flutter/material.dart';

import 'waflo_empty_state.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.message,
    super.key,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return WafloEmptyState(title: title, message: message, icon: icon);
  }
}
