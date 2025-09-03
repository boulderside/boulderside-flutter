import 'package:boulderside_flutter/community/models/board_post.dart';
import 'package:boulderside_flutter/community/models/companion_post.dart';

enum PostType {
  mate,
  board,
}

enum PostSortType {
  latestCreated,
  mostViewed,
  nearestMeetingDate,
}

class UserInfo {
  final String nickname;
  final String? profileImageUrl;

  UserInfo({
    required this.nickname,
    this.profileImageUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      nickname: json['nickname'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
    };
  }
}

class PostResponse {
  final int postId;
  final bool isMine;
  final UserInfo userInfo;
  final String title;
  final String content;
  final PostType postType;
  final int viewCount;
  final DateTime? meetingDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostResponse({
    required this.postId,
    required this.isMine,
    required this.userInfo,
    required this.title,
    required this.content,
    required this.postType,
    required this.viewCount,
    this.meetingDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      postId: json['postId'],
      isMine: json['isMine'] ?? false,
      userInfo: UserInfo.fromJson(json['userInfo']),
      title: json['title'],
      content: json['content'] ?? '',
      postType: _parsePostType(json['postType']),
      viewCount: json['viewCount'] ?? 0,
      meetingDate: json['meetingDate'] != null 
          ? DateTime.parse(json['meetingDate']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static PostType _parsePostType(String type) {
    switch (type.toLowerCase()) {
      case 'mate':
        return PostType.mate;
      case 'board':
        return PostType.board;
      default:
        throw ArgumentError('Unknown post type: $type');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'isMine': isMine,
      'userInfo': userInfo.toJson(),
      'title': title,
      'content': content,
      'postType': postType.name.toUpperCase(),
      'viewCount': viewCount,
      'meetingDate': meetingDate?.toIso8601String().split('T')[0],
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convert to existing model types for backward compatibility
  BoardPost toBoardPost() {
    return BoardPost(
      id: postId,
      title: title,
      authorNickname: userInfo.nickname,
      commentCount: 0, // Not available in PostResponse
      viewCount: viewCount,
      createdAt: createdAt,
      content: content,
    );
  }

  CompanionPost toCompanionPost() {
    return CompanionPost(
      id: postId,
      title: title,
      meetingPlace: '', // Not available in PostResponse
      meetingDateLabel: meetingDate != null 
          ? '${meetingDate!.year}.${meetingDate!.month.toString().padLeft(2, '0')}.${meetingDate!.day.toString().padLeft(2, '0')}'
          : '',
      authorNickname: userInfo.nickname,
      commentCount: 0, // Not available in PostResponse
      viewCount: viewCount,
      createdAt: createdAt,
      content: content,
    );
  }
}

class PostPageResponse {
  final List<PostResponse> content;
  final int? nextCursor;
  final String? nextSubCursor;
  final bool hasNext;
  final int size;

  PostPageResponse({
    required this.content,
    this.nextCursor,
    this.nextSubCursor,
    required this.hasNext,
    required this.size,
  });

  factory PostPageResponse.fromJson(Map<String, dynamic> json) {
    return PostPageResponse(
      content: (json['content'] as List)
          .map((e) => PostResponse.fromJson(e))
          .toList(),
      nextCursor: json['nextCursor'],
      nextSubCursor: json['nextSubCursor'],
      hasNext: json['hasNext'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((e) => e.toJson()).toList(),
      'nextCursor': nextCursor,
      'nextSubCursor': nextSubCursor,
      'hasNext': hasNext,
      'size': size,
    };
  }
}

class CreatePostRequest {
  final String title;
  final String? content;
  final PostType postType;
  final DateTime? meetingDate;

  CreatePostRequest({
    required this.title,
    this.content,
    required this.postType,
    this.meetingDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'postType': postType.name.toUpperCase(),
      'meetingDate': meetingDate?.toIso8601String().split('T')[0],
    };
  }
}