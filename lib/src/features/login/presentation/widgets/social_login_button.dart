import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final String logoPath;
  final VoidCallback onPressed;
  final Color textColor;
  final Color? borderColor;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.logoPath,
    required this.onPressed,
    this.textColor = Colors.white,
    this.borderColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            // 로고를 왼쪽에 배치
            if (!isLoading)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Image.asset(
                  logoPath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            // 로딩 인디케이터를 왼쪽에 배치
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                ),
              ),
            // 텍스트를 중앙에 배치
            Expanded(
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
