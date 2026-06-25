import 'package:flutter/material.dart';

import 'waflo_error_state.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    super.key,
    this.title = 'Something needs attention',
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return WafloErrorState(title: title, message: message, onRetry: onRetry);
  }
}
