import 'board_post.dart';
import 'user_info.dart';

class BoardPostResponse {
  final int boardPostId;
  final bool isMine;
  final UserInfo userInfo;
  final String title;
  final String content;
  final int viewCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  BoardPostResponse({
    required this.boardPostId,
    required this.isMine,
    required this.userInfo,
    required this.title,
    required this.content,
    required this.viewCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  BoardPostResponse copyWith({
    int? boardPostId,
    bool? isMine,
    UserInfo? userInfo,
    String? title,
    String? content,
    int? viewCount,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BoardPostResponse(
      boardPostId: boardPostId ?? this.boardPostId,
      isMine: isMine ?? this.isMine,
      userInfo: userInfo ?? this.userInfo,
      title: title ?? this.title,
      content: content ?? this.content,
      viewCount: viewCount ?? this.viewCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory BoardPostResponse.fromJson(Map<String, dynamic> json) {
    return BoardPostResponse(
      boardPostId: json['boardPostId'] ?? 0,
      isMine: json['isMine'] ?? false,
      userInfo: UserInfo.fromJson(json['userInfo'] ?? {}),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      viewCount: _readInt(json, const [
        'viewCount',
        'viewCnt',
        'views',
        'viewsCount',
      ]),
      commentCount: _readInt(json, const [
        'commentCount',
        'commentCnt',
        'comments',
        'commentsCount',
      ]),
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  BoardPost toBoardPost() {
    return BoardPost(
      id: boardPostId,
      title: title,
      authorNickname: userInfo.nickname,
      commentCount: commentCount,
      viewCount: viewCount,
      createdAt: createdAt,
      content: content,
    );
  }
}

class BoardPostPageResponse {
  final List<BoardPostResponse> content;
  final int? nextCursor;
  final String? nextSubCursor;
  final bool hasNext;
  final int size;

  BoardPostPageResponse({
    required this.content,
    this.nextCursor,
    this.nextSubCursor,
    required this.hasNext,
    required this.size,
  });

  factory BoardPostPageResponse.fromJson(Map<String, dynamic> json) {
    return BoardPostPageResponse(
      content: (json['content'] as List? ?? [])
          .map((e) => BoardPostResponse.fromJson(e))
          .toList(),
      nextCursor: json['nextCursor'],
      nextSubCursor: json['nextSubCursor'],
      hasNext: json['hasNext'] ?? false,
      size: json['size'] ?? 0,
    );
  }
}

class CreateBoardPostRequest {
  final String title;
  final String? content;

  CreateBoardPostRequest({required this.title, this.content});

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content};
  }
}

class UpdateBoardPostRequest {
  final String title;
  final String? content;

  UpdateBoardPostRequest({required this.title, this.content});

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content};
  }
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key) && json[key] != null) {
      final value = json[key];
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
  }
  return 0;
}
