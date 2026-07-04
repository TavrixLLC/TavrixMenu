import 'package:flutter/material.dart';
import '../../../../core/theme/v2/waflo_tokens_v2.dart';

/// Waflo Input V2 Component
///
/// A stylized text form field wrapper utilising Waflo V2 colors, radius, and typography.
class WafloInputV2 extends StatelessWidget {
  const WafloInputV2({
    required this.label,
    super.key,
    this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onSubmitted,
    this.validator,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enableSuggestions;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: WafloTypographyV2.bodyBold.copyWith(
            color: WafloColorsV2.textDark,
          ),
        ),
        const SizedBox(height: WafloSpacingV2.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          obscureText: obscureText,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          style: WafloTypographyV2.body.copyWith(color: WafloColorsV2.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: WafloTypographyV2.body.copyWith(
              color: WafloColorsV2.textLight,
            ),
            filled: true,
            fillColor: WafloColorsV2.surfaceWhite,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: WafloColorsV2.textLight, size: 20)
                : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: WafloRadiusV2.mdBorder,
              borderSide: const BorderSide(color: WafloColorsV2.borderSoft),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: WafloRadiusV2.mdBorder,
              borderSide: const BorderSide(color: WafloColorsV2.borderSoft),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: WafloRadiusV2.mdBorder,
              borderSide: const BorderSide(
                color: WafloColorsV2.primaryCoral,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: WafloRadiusV2.mdBorder,
              borderSide: const BorderSide(color: WafloColorsV2.danger),
            ),
          ),
        ),
      ],
    );
  }
}
