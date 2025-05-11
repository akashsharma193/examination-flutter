import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/core/constants/textstyles_constants.dart';

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
            style: AppTextStyles.body,
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: AppTextStyles.subheading,
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
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
              if (widget.isEmail && !value!.isEmail) {
                return "Enter a valid email";
              }
              if (widget.isPassword &&
                  !RegExp(r'^(?=.*[!@#\$%^&*(),.?":{}|<>]).{6,}')
                      .hasMatch(value ?? '')) {
                return "Password must contain one special symbol and be 6+ chars long";
              }
              return null;
            },
          ),
        
        const SizedBox(height: 10),
      ],
    );
  }
}
