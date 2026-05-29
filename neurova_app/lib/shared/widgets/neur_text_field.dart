import 'package:flutter/material.dart';
import 'neur_card.dart';

/// NeurTextField - Styled input field with glow on focus
/// Dark background, rounded, subtle border glow on focus
class NeurTextField extends StatefulWidget {
  final String hint;
  final TextEditingController? controller;
  final int? maxLines;
  final int? minLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;

  const NeurTextField({
    super.key,
    required this.hint,
    this.controller,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction,
    this.focusNode,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
  });

  @override
  State<NeurTextField> createState() => _NeurTextFieldState();
}

class _NeurTextFieldState extends State<NeurTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>()!;
    const kLilac = Color(0xFFC8B8E8);
    const kLilacBorder = Color(0xFFD0C0E8);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: kLilac.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        minLines: widget.minLines,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        validator: widget.validator,
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        style: TextStyle(
          fontFamily: 'Syne',
          fontSize: 14,
          color: nc.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            fontFamily: 'Syne',
            fontSize: 14,
            color: nc.textMuted,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: nc.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: nc.divider,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: nc.divider,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: kLilacBorder,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF5350),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF5350),
              width: 2,
            ),
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: nc.textSecondary, size: 20)
              : null,
          suffixIcon: widget.suffixIcon != null
              ? GestureDetector(
                  onTap: widget.onSuffixTap,
                  child: Icon(
                    widget.suffixIcon,
                    color: nc.textSecondary,
                    size: 20,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

/// NeurPasswordField - Specialized TextField with show/hide toggle
class NeurPasswordField extends StatefulWidget {
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const NeurPasswordField({
    super.key,
    required this.hint,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  State<NeurPasswordField> createState() => _NeurPasswordFieldState();
}

class _NeurPasswordFieldState extends State<NeurPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return NeurTextField(
      hint: widget.hint,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      obscureText: _obscureText,
      suffixIcon: _obscureText ? Icons.visibility_off : Icons.visibility,
      onSuffixTap: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    );
  }
}
