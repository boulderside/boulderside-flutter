import 'package:flutter/material.dart';

class PostSkeletonList extends StatelessWidget {
  const PostSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF262A34),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(widthFactor: 0.7),
                SizedBox(height: 8),
                _SkeletonLine(widthFactor: 0.4),
                SizedBox(height: 12),
                _SkeletonLine(widthFactor: 1),
                SizedBox(height: 6),
                _SkeletonLine(widthFactor: 0.9),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double widthFactor;

  const _SkeletonLine({required this.widthFactor});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: const Color(0xFF3A3F4F),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
