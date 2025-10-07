import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TextFieldType {
  email,
  password,
  number,
  text,
}

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextFieldType type;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const AppTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.type = TextFieldType.text,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.onChanged,
    this.onTap,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.type == TextFieldType.password;
  }

  TextInputType get _keyboardType {
    switch (widget.type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.number:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? get _inputFormatters {
    if (widget.type == TextFieldType.number) {
      return [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ];
    }
    return null;
  }

  void _validate(String value) {
    if (widget.type == TextFieldType.email) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
      setState(() {
        _errorText = value.isEmpty || emailRegex.hasMatch(value)
            ? null
            : 'Invalid email address';
      });
    } else if (widget.type == TextFieldType.number) {
      setState(() {
        _errorText = value.length > 10 ? 'Max 10 digits' : null;
      });
    } else {
      setState(() {
        _errorText = null;
      });
    }

    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  Widget? _buildSuffixIcon() {
    if (widget.type == TextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.black54,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.type == TextFieldType.password ? _obscureText : false,
      keyboardType: _keyboardType,
      inputFormatters: _inputFormatters,
      validator: widget.validator ??
          (value) => AppValidators.validate(widget.type, value),
      onChanged: _validate,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      focusNode: widget.focusNode,
      onTap: widget.onTap,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.enabled ? const Color(0xCCF0EDFF) : Colors.grey[200],
        prefixIcon: widget.prefixIcon,
        hintText: widget.hintText,
        errorText: _errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF7460F1),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        suffixIcon: _buildSuffixIcon(),
      ),
    );
  }
}

class AppValidators {
  static String? validate(TextFieldType type, String? value) {
    switch (type) {
      case TextFieldType.email:
        if (value == null || value.isEmpty) return 'Email is required';
        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!emailRegex.hasMatch(value)) return 'Invalid email address';
        return null;

      case TextFieldType.password:
        if (value == null || value.isEmpty) return 'Password is required';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;

      case TextFieldType.number:
        if (value == null || value.isEmpty) return 'Number is required';
        if (!RegExp(r'^\d+$').hasMatch(value)) return 'Only digits allowed';
        if (value.length > 10) return 'Max 10 digits allowed';
        return null;

      case TextFieldType.text:
      default:
        if (value == null || value.isEmpty) return 'This field is required';
        return null;
    }
  }
}
