import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AvatarPlaceholder extends StatelessWidget {
  const AvatarPlaceholder({
    super.key,
    this.imageUrl,
    this.size = 32,
    this.backgroundColor = const Color(0xFF262A34),
    this.iconColor = Colors.white54,
    this.placeholderIcon = CupertinoIcons.person_fill,
  });

  final String? imageUrl;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final IconData placeholderIcon;

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
      clipBehavior: Clip.antiAlias,
      child: _hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _FallbackIcon(
                icon: placeholderIcon,
                color: iconColor,
                size: size * 0.6,
              ),
            )
          : _FallbackIcon(
              icon: placeholderIcon,
              color: iconColor,
              size: size * 0.6,
            ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(icon, color: color, size: size),
    );
  }
}
