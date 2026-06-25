import 'package:flutter/material.dart';

import 'waflo_error_state.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, super.key, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return WafloErrorState(message: message, onRetry: onRetry);
  }
}
