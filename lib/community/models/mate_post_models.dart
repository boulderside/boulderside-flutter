import 'companion_post.dart';
import 'user_info.dart';

class MatePostResponse {
  final int matePostId;
  final bool isMine;
  final UserInfo userInfo;
  final String title;
  final String content;
  final int viewCount;
  final int commentCount;
  final DateTime meetingDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  MatePostResponse({
    required this.matePostId,
    required this.isMine,
    required this.userInfo,
    required this.title,
    required this.content,
    required this.viewCount,
    required this.commentCount,
    required this.meetingDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MatePostResponse.fromJson(Map<String, dynamic> json) {
    final id = json['matePostId'] ?? json['id'] ?? 0;
    return MatePostResponse(
      matePostId: id,
      isMine: json['isMine'] ?? false,
      userInfo: UserInfo.fromJson(json['userInfo'] ?? {}),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      meetingDate: DateTime.tryParse(json['meetingDate'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  CompanionPost toCompanionPost() {
    final dateLabel = '${meetingDate.year}.${meetingDate.month.toString().padLeft(2, '0')}.${meetingDate.day.toString().padLeft(2, '0')}';
    return CompanionPost(
      id: matePostId,
      title: title,
      meetingPlace: '',
      meetingDateLabel: dateLabel,
      authorNickname: userInfo.nickname,
      commentCount: commentCount,
      viewCount: viewCount,
      createdAt: createdAt,
      content: content,
    );
  }
}

class MatePostPageResponse {
  final List<MatePostResponse> content;
  final int? nextCursor;
  final String? nextSubCursor;
  final bool hasNext;
  final int size;

  MatePostPageResponse({
    required this.content,
    this.nextCursor,
    this.nextSubCursor,
    required this.hasNext,
    required this.size,
  });

  factory MatePostPageResponse.fromJson(Map<String, dynamic> json) {
    return MatePostPageResponse(
      content: (json['content'] as List? ?? [])
          .map((e) => MatePostResponse.fromJson(e))
          .toList(),
      nextCursor: json['nextCursor'],
      nextSubCursor: json['nextSubCursor'],
      hasNext: json['hasNext'] ?? false,
      size: json['size'] ?? 0,
    );
  }
}

class CreateMatePostRequest {
  final String title;
  final String? content;
  final DateTime meetingDate;

  CreateMatePostRequest({
    required this.title,
    this.content,
    required this.meetingDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'meetingDate': meetingDate.toIso8601String().split('T')[0],
    };
  }
}

class UpdateMatePostRequest {
  final String title;
  final String? content;
  final DateTime meetingDate;

  UpdateMatePostRequest({
    required this.title,
    this.content,
    required this.meetingDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'meetingDate': meetingDate.toIso8601String().split('T')[0],
    };
  }
}
