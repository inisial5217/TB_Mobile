import 'package:flutter/material.dart';

// custom widget text field dengan validasi
class CustomTextField extends StatelessWidget {
  final TextEditingController controller; // param controller
  final String hintText; // param hint text
  final bool obscureText; // param sembunyikan teks
  final String? Function(String?)? validator; // param validasi
  final Widget? prefixIcon; // param ikon kiri
  final Widget? suffixIcon; // param ikon kanan
  final TextInputType? keyboardType; // param tipe keyboard
  final int maxLines; // param baris maksimal
  final bool readOnly; // param read only

  // constructor init
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
