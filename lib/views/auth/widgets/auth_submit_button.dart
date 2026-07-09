import 'package:flutter/material.dart';

class AuthSubmitButton extends StatelessWidget {
  final String label;
  final String successLabel;
  final bool isLoading;
  final bool isSuccess;
  final VoidCallback onPressed;

  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.successLabel,
    required this.isLoading,
    required this.isSuccess,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (isLoading || isSuccess) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isSuccess
            ? const Color(0xFF22C55E)
            : const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        disabledBackgroundColor: isSuccess
            ? const Color(0xFF22C55E)
            : const Color(0xFF2563EB).withValues(alpha: 0.6),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : isSuccess
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  successLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
