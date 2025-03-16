import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? errorMessage;
  final bool isRequired;
  final bool isEmail;
  final bool isPassword;
  final bool isMobile;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.errorMessage,
    this.isRequired = true,
    this.isEmail = false,
    this.isPassword = false,
    this.isMobile = false,
    this.maxLength,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  bool isObscurePass = true; // Password visibility state

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? isObscurePass : false,
          keyboardType: widget.isEmail
              ? TextInputType.emailAddress
              : widget.isMobile
                  ? TextInputType.phone
                  : TextInputType.text,
          inputFormatters: widget.isMobile
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
              : widget.maxLength != null
                  ? [LengthLimitingTextInputFormatter(widget.maxLength)]
                  : [],
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isObscurePass = !isObscurePass;
                      });
                    },
                    icon: Icon(
                      isObscurePass ? Icons.visibility : Icons.visibility_off,
                    ),
                  )
                : null,
          ),
          validator: (value) {
            if (widget.isRequired && (value == null || value.trim().isEmpty)) {
              return widget.errorMessage ?? "This field is required";
            }
            if (widget.isEmail &&
                !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value ?? "")) {
              return "Enter a valid email";
            }
            if (widget.isPassword &&
                !RegExp(r'^(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$')
                    .hasMatch(value ?? '')) {
              return "Password must contain one special symbol and 6 char long";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
