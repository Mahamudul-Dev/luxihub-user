import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../config/utils.dart';

class TextInputField extends StatefulWidget {
  const TextInputField({
    super.key,

    // Controller & focus
    this.controller,
    this.focusNode,
    this.initialValue,

    // Label / hint / helper / error
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.counterText,

    // Prefix / suffix
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,

    // Obscure / password
    this.obscureText = false,
    this.showPasswordToggle = false,

    // Keyboard & input behavior
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,

    // Callbacks
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.validator,

    // Styling
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.disabledBorderColor,
    this.borderRadius,
    this.borderWidth = 1.0,
    this.focusedBorderWidth = 1.5,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.floatingLabelStyle,
    this.textAlign = TextAlign.start,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,

    // Form
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;

  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? counterText;

  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final String? prefixText;
  final String? suffixText;

  final bool obscureText;
  final bool showPasswordToggle;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final GestureTapCallback? onTap;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;

  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? disabledBorderColor;
  final double? borderRadius;
  final double borderWidth;
  final double focusedBorderWidth;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? floatingLabelStyle;
  final TextAlign textAlign;
  final FloatingLabelBehavior floatingLabelBehavior;

  final AutovalidateMode autovalidateMode;

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  void _toggleObscure() => setState(() => _obscured = !_obscured);

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        widget.borderRadius ?? Utils.defaultBorderRadius,
      ),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget? get _resolvedSuffixIcon {
    if (widget.showPasswordToggle && widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AppColors.textHint,
        ),
        onPressed: _toggleObscure,
        splashRadius: 20,
      );
    }
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? Utils.defaultBorderRadius;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      initialValue: widget.initialValue,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      onEditingComplete: widget.onEditingComplete,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      textAlign: widget.textAlign,
      style: widget.textStyle ?? AppTextStyles.inputText,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,
        counterText: widget.counterText ?? (widget.maxLength != null ? null : ''),
        prefixIcon: widget.prefixIcon,
        suffixIcon: _resolvedSuffixIcon,
        prefix: widget.prefix,
        suffix: widget.suffix,
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
        filled: true,
        fillColor: widget.enabled
            ? (widget.fillColor ?? AppColors.inputFill)
            : AppColors.surfaceBackground,
        hintStyle: widget.hintStyle ?? AppTextStyles.inputHint,
        labelStyle: widget.labelStyle ??
            AppTextStyles.inputHint.copyWith(color: AppColors.textSecondary),
        floatingLabelStyle: widget.floatingLabelStyle ??
            AppTextStyles.inputHint.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
        floatingLabelBehavior: widget.floatingLabelBehavior,
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: _border(
          widget.borderColor ?? AppColors.inputBorder,
          widget.borderWidth,
        ),
        focusedBorder: _border(
          widget.focusedBorderColor ?? AppColors.inputFocusedBorder,
          widget.focusedBorderWidth,
        ),
        errorBorder: _border(
          widget.errorBorderColor ?? AppColors.error,
          widget.borderWidth,
        ),
        focusedErrorBorder: _border(
          widget.errorBorderColor ?? AppColors.error,
          widget.focusedBorderWidth,
        ),
        disabledBorder: _border(
          widget.disabledBorderColor ??
              AppColors.inputBorder.withValues(alpha: 0.5),
          widget.borderWidth,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
