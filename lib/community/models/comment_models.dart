import 'user_info.dart';

enum CommentDomainType {
  boardPost,
  matePost,
  route,
}

extension CommentDomainTypeExtension on CommentDomainType {
  String get apiPath {
    switch (this) {
      case CommentDomainType.boardPost:
        return 'board-posts';
      case CommentDomainType.matePost:
        return 'mate-posts';
      case CommentDomainType.route:
        return 'routes';
    }
  }
}

class CommentResponseModel {
  final int commentId;
  final CommentDomainType commentDomainType;
  final int domainId;
  final bool isMine;
  final UserInfo userInfo;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommentResponseModel({
    required this.commentId,
    required this.commentDomainType,
    required this.domainId,
    required this.isMine,
    required this.userInfo,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentResponseModel.fromJson(Map<String, dynamic> json) {
    return CommentResponseModel(
      commentId: json['commentId'] ?? 0,
      commentDomainType: _parseCommentDomainType(json['commentDomainType'] ?? ''),
      domainId: json['domainId'] ?? 0,
      isMine: json['isMine'] ?? false,
      userInfo: UserInfo.fromJson(json['userInfo'] ?? {}),
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static CommentDomainType _parseCommentDomainType(String type) {
    switch (type.toUpperCase()) {
      case 'BOARD_POST':
        return CommentDomainType.boardPost;
      case 'MATE_POST':
        return CommentDomainType.matePost;
      case 'ROUTE':
        return CommentDomainType.route;
      default:
        return CommentDomainType.boardPost;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'commentDomainType': commentDomainType.name.toUpperCase(),
      'domainId': domainId,
      'isMine': isMine,
      'userInfo': userInfo.toJson(),
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CommentPageResponseModel {
  final List<CommentResponseModel> content;
  final int nextCursor;
  final bool hasNext;
  final int size;

  CommentPageResponseModel({
    required this.content,
    required this.nextCursor,
    required this.hasNext,
    required this.size,
  });

  factory CommentPageResponseModel.fromJson(Map<String, dynamic> json) {
    return CommentPageResponseModel(
      content: (json['content'] ?? [])
          .map<CommentResponseModel>((e) => CommentResponseModel.fromJson(e))
          .toList(),
      nextCursor: json['nextCursor'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      size: json['size'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((e) => e.toJson()).toList(),
      'nextCursor': nextCursor,
      'hasNext': hasNext,
      'size': size,
    };
  }
}

class CreateCommentRequest {
  final String content;

  CreateCommentRequest({
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}

class UpdateCommentRequest {
  final String content;

  UpdateCommentRequest({
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}
