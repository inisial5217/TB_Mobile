import 'package:flutter/material.dart';
import 'package:tb_ecommerce/core/theme.dart';

// custom widget tombol utama dengan loading state
class PrimaryButton extends StatelessWidget {
  final String text; // param teks tombol
  final VoidCallback? onPressed; // param aksi klik
  final bool isLoading; // param status loading
  final Color? backgroundColor; // param warna latar
  final Color? foregroundColor; // param warna teks
  final IconData? icon; // param ikon opsional

  // constructor init
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // prevent double click
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.emeraldGreen,
          foregroundColor: foregroundColor ?? Colors.white,
          disabledBackgroundColor:
              (backgroundColor ?? AppTheme.emeraldGreen)
                  .withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
