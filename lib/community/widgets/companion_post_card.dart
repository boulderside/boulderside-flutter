import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/companion_post.dart';
import '../../core/routes/app_routes.dart';

class CompanionPostCard extends StatelessWidget {
  final CompanionPost post;
  const CompanionPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.communityCompanionDetail,
            arguments: post,
          );
        },
        child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: const Color(0xFF262A34),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              // Location row removed per requirement
              Row(
                children: [
                  const Icon(CupertinoIcons.calendar, size: 18, color: Color(0xFF7C7C7C)),
                  const SizedBox(width: 6),
                  Text(
                    post.meetingDateLabel,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.person_fill, size: 18, color: Color(0xFF7C7C7C)),
                      const SizedBox(width: 6),
                      Text(
                        post.authorNickname,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.chat_bubble_text, size: 18, color: Color(0xFF7C7C7C)),
                      const SizedBox(width: 4),
                      Text('${post.commentCount}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                      const SizedBox(width: 12),
                      const Icon(CupertinoIcons.eye, size: 18, color: Color(0xFF7C7C7C)),
                      const SizedBox(width: 4),
                      Text('${post.viewCount}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _timeAgo(post.createdAt),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Color(0xFFB0B3B8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);
    if (duration.inMinutes < 1) return '방금 전';
    if (duration.inHours < 1) return '${duration.inMinutes}분 전';
    if (duration.inDays < 1) return '${duration.inHours}시간 전';
    if (duration.inDays < 7) return '${duration.inDays}일 전';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
