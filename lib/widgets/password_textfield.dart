import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final Color borderColor;
  final Color iconColor;
  final Color labelColor;
  final String? errorText;
  final void Function(String)? onChanged; // ✅ Sửa ở đây

  PasswordTextField({
    required this.controller,
    required this.labelText,
    required this.borderColor,
    required this.iconColor,
    required this.labelColor,
    this.errorText,
    this.onChanged,
  });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: widget.onChanged, // ✅ Sửa ở đây
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: widget.labelColor),
        errorText: widget.errorText,
        prefixIcon: Icon(Icons.lock_outline, color: widget.iconColor),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: widget.iconColor,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}