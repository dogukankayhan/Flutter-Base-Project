import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base_kit/core/enums/app_icon.dart';
import 'package:flutter_kit_ui/theme/app_brand_colors.dart';
import 'package:flutter_kit_ui/theme/app_colors.dart';
import 'package:flutter_kit_ui/theme/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum InputType { text, password, numeric, email, phone }

/// Usage:
///   AppTextField(label: 'E-posta', controller: _ctrl, hintText: 'ornek@mail.com', type: InputType.email)
///   AppTextField(label: 'Password',   controller: _ctrl, hintText: '••••••••',       type: InputType.password)
///   AppTextField(label: 'Note',     controller: _ctrl, hintText: 'Enter description', maxLines: 4)
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.type = InputType.text,
    this.isRequired = false,
    this.isEnabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.focusNode,
    this.validator,
    this.validationMessage,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final InputType type;
  final bool isRequired;
  final bool isEnabled;
  final Widget? prefixIcon;

  /// Automatic toggle icon is created for password type,
  /// this field is only applicable for text/numeric/email/phone.
  final SvgIcon? suffixIcon;

  final int maxLines;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;

  /// To provide direct error message from outside instead of validator message.
  final String? validationMessage;
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  final _isFocused = ValueNotifier<bool>(false);
  final _isPasswordVisible = ValueNotifier<bool>(false);

  bool get _isPassword => widget.type == InputType.password;
  bool get _isMultiline => !_isPassword && widget.maxLines > 1;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _isFocused.dispose();
    _isPasswordVisible.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() => _isFocused.value = _focusNode.hasFocus;

  // ─── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ValueListenableBuilder<bool>(
      valueListenable: _isPasswordVisible,
      builder: (context, passwordVisible, _) {
        final field = TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: _isPassword && !passwordVisible,
          keyboardType: _keyboardType,
          inputFormatters: _inputFormatters,
          maxLines: _isPassword ? 1 : widget.maxLines,
          minLines: _isPassword ? 1 : widget.maxLines,
          enabled: widget.isEnabled,
          onChanged: widget.onChanged,
          style: context.textStyle.paragraph16Regular.copyWith(
            color: colors.textColor,
          ),
          validator:
              widget.validator ??
              (widget.isRequired ? _requiredValidator : null),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          decoration: _decoration(context, colors),
        );

        if (!_isMultiline) return field;

        // Multiline: show resize handle
        return Stack(
          children: [
            field,
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.w, right: 8.w),
                child: SvgIcon.resizeHandle(width: 8.w, height: 8.w),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Decoration ─────────────────────────────────────────
  InputDecoration _decoration(BuildContext context, AppColors colors) {
    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: context.textStyle.paragraph16Regular.copyWith(
        color: AppBrandColors.textFieldUnFocusText,
      ),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      label: _label(context),
      prefixIcon: widget.prefixIcon != null
          ? Padding(padding: EdgeInsets.all(12.w), child: widget.prefixIcon)
          : null,
      suffixIcon: _suffixIcon(colors),
      errorText: widget.validationMessage,
      errorStyle: context.textStyle.paragraph14Regular.copyWith(
        color: AppBrandColors.error,
      ),
      border: _border(AppBrandColors.textFieldUnFocusBorder),
      enabledBorder: _border(AppBrandColors.textFieldUnFocusBorder),
      focusedBorder: _border(AppBrandColors.textFieldFocusBorder),
      errorBorder: _border(AppBrandColors.error),
      focusedErrorBorder: _border(AppBrandColors.error),
      disabledBorder: _border(AppBrandColors.textFieldDisabledBorder),
    );
  }

  Widget _label(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: widget.label,
        style: context.textStyle.paragraph16Regular,
        children: [
          if (widget.isRequired)
            TextSpan(
              text: ' *',
              style: context.textStyle.paragraph16Regular.copyWith(
                color: AppBrandColors.error,
              ),
            ),
        ],
      ),
    );
  }

  Widget? _suffixIcon(AppColors colors) {
    if (_isPassword) {
      return ValueListenableBuilder<bool>(
        valueListenable: _isPasswordVisible,
        builder: (_, visible, _) => IconButton(
          icon: (visible ? SvgIcon.eye : SvgIcon.eyeSlash).call(
            color: AppBrandColors.textFieldUnFocusBorder,
          ),
          onPressed: () => _isPasswordVisible.value = !_isPasswordVisible.value,
        ),
      );
    }

    if (widget.suffixIcon != null) {
      return Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: ValueListenableBuilder<bool>(
          valueListenable: _isFocused,
          builder: (_, focused, _) => SizedBox.square(
            dimension: 20.w,
            child: Center(
              child: widget.suffixIcon!.call(
                color: focused
                    ? AppBrandColors.textFieldFocusBorder
                    : AppBrandColors.textFieldUnFocusBorder,
              ),
            ),
          ),
        ),
      );
    }

    return null;
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: BorderSide(color: color, width: 1.5.w),
  );

  // ─── Keyboard / Formatter ───────────────────────────────
  TextInputType get _keyboardType => switch (widget.type) {
    InputType.text => TextInputType.text,
    InputType.password => TextInputType.visiblePassword,
    InputType.numeric => TextInputType.number,
    InputType.email => TextInputType.emailAddress,
    InputType.phone => TextInputType.phone,
  };

  List<TextInputFormatter>? get _inputFormatters => switch (widget.type) {
    InputType.numeric ||
    InputType.phone => [FilteringTextInputFormatter.digitsOnly],
    _ => null,
  };

  // ─── Default validator ──────────────────────────────────
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan boş bırakılamaz';
    return null;
  }
}
