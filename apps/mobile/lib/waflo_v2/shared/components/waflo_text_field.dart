import 'package:flutter/material.dart';

class WafloTextField extends StatelessWidget {
  const WafloTextField({
    required this.label,
    super.key,
    this.controller,
    this.initialValue,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textDirection,
    this.maxLines = 1,
    this.leading,
    this.onChanged,
  }) : assert(controller == null || initialValue == null);

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final int maxLines;
  final IconData? leading;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textDirection: textDirection,
      maxLines: maxLines,
      onChanged: enabled && !readOnly ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: leading == null ? null : Icon(leading),
      ),
    );
  }
}
