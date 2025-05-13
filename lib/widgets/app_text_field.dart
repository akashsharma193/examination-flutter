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
  final TextFieldType type;

  const AppTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.type = TextFieldType.text,
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
  }

  @override
  Widget build(BuildContext context) {
    return  TextField(
        controller: widget.controller,
        obscureText: widget.type == TextFieldType.password ? _obscureText : false,
        keyboardType: _keyboardType,
        inputFormatters: _inputFormatters,
        onChanged: _validate,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xCCF0EDFF), // 80% opacity
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
              color: Color(0xFF7460F1), // Deep purple color
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          suffixIcon: widget.type == TextFieldType.password
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      )
    ;
  }
} 