import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/domain/entities/image_info_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/companion_post.dart';

enum DocumentDomainType { boulder, route, boardPost, matePost }

extension DocumentDomainTypeExtension on DocumentDomainType {
  String toServerString() {
    switch (this) {
      case DocumentDomainType.boulder:
        return 'BOULDER';
      case DocumentDomainType.route:
        return 'ROUTE';
      case DocumentDomainType.boardPost:
        return 'BOARD_POST';
      case DocumentDomainType.matePost:
        return 'MATE_POST';
    }
  }
}

class AutocompleteResponse {
  final List<String> suggestionList;

  AutocompleteResponse({required this.suggestionList});

  factory AutocompleteResponse.fromJson(Map<String, dynamic> json) {
    return AutocompleteResponse(
      suggestionList: (json['suggestionList'] as List)
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class UnifiedSearchResponse {
  final Map<DocumentDomainType, DomainSearchResult> domainResults;
  final Map<DocumentDomainType, int> totalCounts;

  UnifiedSearchResponse({
    required this.domainResults,
    required this.totalCounts,
  });

  factory UnifiedSearchResponse.fromJson(Map<String, dynamic> json) {
    final domainResultsJson = json['domainResults'] as Map<String, dynamic>;
    final totalCountsJson = json['totalCounts'] as Map<String, dynamic>;

    final domainResults = <DocumentDomainType, DomainSearchResult>{};
    final totalCounts = <DocumentDomainType, int>{};

    for (final entry in domainResultsJson.entries) {
      final domainType = _parseDomainType(entry.key);
      domainResults[domainType] = DomainSearchResult.fromJson(entry.value);
    }

    for (final entry in totalCountsJson.entries) {
      final domainType = _parseDomainType(entry.key);
      totalCounts[domainType] = entry.value as int;
    }

    return UnifiedSearchResponse(
      domainResults: domainResults,
      totalCounts: totalCounts,
    );
  }

  static DocumentDomainType _parseDomainType(String type) {
    switch (type.toUpperCase()) {
      case 'BOULDER':
        return DocumentDomainType.boulder;
      case 'ROUTE':
        return DocumentDomainType.route;
      case 'BOARD_POST':
        return DocumentDomainType.boardPost;
      case 'MATE_POST':
        return DocumentDomainType.matePost;
      default:
        throw ArgumentError('Unknown domain type: $type');
    }
  }
}

class DomainSearchResult {
  final List<SearchItemResponse> items;
  final bool hasMore;

  DomainSearchResult({required this.items, required this.hasMore});

  factory DomainSearchResult.fromJson(Map<String, dynamic> json) {
    return DomainSearchResult(
      items: (json['items'] as List)
          .map((e) => SearchItemResponse.fromJson(e))
          .toList(),
      hasMore: json['hasMore'],
    );
  }
}

// SearchItemDetails - polymorphic details for search items
sealed class SearchItemDetails {
  const SearchItemDetails();

  factory SearchItemDetails.fromJson(Map<String, dynamic> json, String type) {
    switch (type.toUpperCase()) {
      case 'BOULDER':
        return BoulderDetails.fromJson(json);
      case 'ROUTE':
        return RouteDetails.fromJson(json);
      case 'BOARD_POST':
        return BoardPostDetails.fromJson(json);
      case 'MATE_POST':
        return MatePostDetails.fromJson(json);
      default:
        throw ArgumentError('Unknown detail type: $type');
    }
  }
}

class BoulderDetails extends SearchItemDetails {
  final String? thumbnailUrl;
  final String? province;
  final String? city;
  final int? likeCount;
  final int? viewCount;
  final String boulderName;

  const BoulderDetails({
    this.thumbnailUrl,
    this.province,
    this.city,
    this.likeCount,
    this.viewCount,
    required this.boulderName,
  });

  factory BoulderDetails.fromJson(Map<String, dynamic> json) {
    return BoulderDetails(
      thumbnailUrl: json['thumbnailUrl'],
      province: json['province'],
      city: json['city'],
      likeCount: json['likeCount'],
      viewCount: json['viewCount'],
      boulderName: json['boulderName'] ?? '',
    );
  }
}

class RouteDetails extends SearchItemDetails {
  final String routeName;
  final String? level;
  final int? likeCount;
  final int? climberCount;
  final String? boulderName;

  const RouteDetails({
    required this.routeName,
    this.level,
    this.likeCount,
    this.climberCount,
    this.boulderName,
  });

  factory RouteDetails.fromJson(Map<String, dynamic> json) {
    return RouteDetails(
      routeName: json['routeName'] ?? '',
      level: json['level'],
      likeCount: json['likeCount'],
      climberCount: json['climberCount'],
      boulderName: json['boulderName'],
    );
  }
}

class BoardPostDetails extends SearchItemDetails {
  final String title;
  final String? authorName;
  final int? commentCount;
  final int? viewCount;

  const BoardPostDetails({
    required this.title,
    this.authorName,
    this.commentCount,
    this.viewCount,
  });

  factory BoardPostDetails.fromJson(Map<String, dynamic> json) {
    return BoardPostDetails(
      title: json['title'] ?? '',
      authorName: json['authorName'],
      commentCount: _parseNullableInt(json['commentCount']),
      viewCount: _parseNullableInt(json['viewCount']),
    );
  }
}

class MatePostDetails extends SearchItemDetails {
  final String title;
  final String? authorName;
  final int? commentCount;
  final int? viewCount;
  final DateTime? meetingDate;

  const MatePostDetails({
    required this.title,
    this.authorName,
    this.commentCount,
    this.viewCount,
    this.meetingDate,
  });

  factory MatePostDetails.fromJson(Map<String, dynamic> json) {
    return MatePostDetails(
      title: json['title'] ?? '',
      authorName: json['authorName'],
      commentCount: _parseNullableInt(json['commentCount']),
      viewCount: _parseNullableInt(json['viewCount']),
      meetingDate: json['meetingDate'] != null
          ? DateTime.parse(json['meetingDate'])
          : null,
    );
  }
}

// Helper function for safe integer parsing
int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

class SearchItemResponse {
  final String id;
  final DocumentDomainType domainType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SearchItemDetails details;

  SearchItemResponse({
    required this.id,
    required this.domainType,
    required this.createdAt,
    required this.updatedAt,
    required this.details,
  });

  factory SearchItemResponse.fromJson(Map<String, dynamic> json) {
    final domainTypeStr = json['domainType'] as String;
    final domainType = UnifiedSearchResponse._parseDomainType(domainTypeStr);
    final detailsJson = json['details'] as Map<String, dynamic>;

    return SearchItemResponse(
      id: json['id'],
      domainType: domainType,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      details: SearchItemDetails.fromJson(detailsJson, domainTypeStr),
    );
  }

  // Helper getters for backward compatibility
  String get title {
    return switch (details) {
      BoulderDetails d => d.boulderName,
      RouteDetails d => d.routeName,
      BoardPostDetails d => d.title,
      MatePostDetails d => d.title,
    };
  }

  // Convert to existing model types for compatibility
  BoulderModel toBoulderModel() {
    if (details is! BoulderDetails) {
      throw StateError('Cannot convert non-boulder details to BoulderModel');
    }
    final boulderDetails = details as BoulderDetails;

    final parsedId = int.tryParse(id);
    if (parsedId == null) {
      throw FormatException('Cannot parse id "$id" to int for BoulderModel');
    }

    final List<ImageInfoModel> images =
        boulderDetails.thumbnailUrl != null &&
            boulderDetails.thumbnailUrl!.isNotEmpty
        ? [
            ImageInfoModel(
              targetType: 'BOULDER',
              imageUrl: boulderDetails.thumbnailUrl!,
              orderIndex: 0,
            ),
          ]
        : <ImageInfoModel>[];

    return BoulderModel(
      id: parsedId,
      name: boulderDetails.boulderName,
      description: '',
      sectorName: '',
      areaCode: '',
      latitude: 0.0,
      longitude: 0.0,
      province: boulderDetails.province ?? '',
      city: boulderDetails.city ?? '',
      likeCount: boulderDetails.likeCount ?? 0,
      viewCount: boulderDetails.viewCount ?? 0,
      imageInfoList: images,
      liked: false,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  RouteModel toRouteModel() {
    if (details is! RouteDetails) {
      throw StateError('Cannot convert non-route details to RouteModel');
    }
    final routeDetails = details as RouteDetails;

    final parsedId = int.tryParse(id);
    if (parsedId == null) {
      throw FormatException('Cannot parse id "$id" to int for RouteModel');
    }

    return RouteModel(
      id: parsedId,
      boulderId: 0,
      province: '',
      city: '',
      name: routeDetails.routeName,
      pioneerName: '',
      latitude: 0.0,
      longitude: 0.0,
      sectorName: '',
      areaCode: '',
      routeLevel: routeDetails.level ?? '',
      boulderName: routeDetails.boulderName,
      likeCount: routeDetails.likeCount ?? 0,
      liked: false,
      viewCount: 0,
      climberCount: routeDetails.climberCount ?? 0,
      commentCount: 0,
      imageInfoList: [],
      createdAt: createdAt,
      updatedAt: updatedAt,
      completed: false,
    );
  }

  // Convert to existing model types for compatibility
  // ... (previous methods)

  CompanionPost toCompanionPost() {
    if (details is! MatePostDetails) {
      throw StateError('Cannot convert non-mate post details to CompanionPost');
    }
    final mateDetails = details as MatePostDetails;

    final parsedId = int.tryParse(id);
    if (parsedId == null) {
      throw FormatException('Cannot parse id "$id" to int for CompanionPost');
    }

    final meetingDate = mateDetails.meetingDate;

    return CompanionPost(
      id: parsedId,
      title: mateDetails.title,
      meetingPlace: '',
      meetingDateLabel: meetingDate != null
          ? '${meetingDate.year}.${meetingDate.month.toString().padLeft(2, '0')}.${meetingDate.day.toString().padLeft(2, '0')}'
          : '',
      authorNickname: mateDetails.authorName ?? '',
      commentCount: mateDetails.commentCount ?? 0,
      viewCount: mateDetails.viewCount ?? 0,
      createdAt: createdAt,
      content: null,
    );
  }

  BoardPost toBoardPost() {
    if (details is! BoardPostDetails) {
      throw StateError('Cannot convert non-board post details to BoardPost');
    }
    final boardDetails = details as BoardPostDetails;

    final parsedId = int.tryParse(id);
    if (parsedId == null) {
      throw FormatException('Cannot parse id "$id" to int for BoardPost');
    }

    return BoardPost(
      id: parsedId,
      title: boardDetails.title,
      authorNickname: boardDetails.authorName ?? '',
      commentCount: boardDetails.commentCount ?? 0,
      viewCount: boardDetails.viewCount ?? 0,
      createdAt: createdAt,
      content: null,
    );
  }
}

class DomainSearchResponse {
  final List<SearchItemResponse> items;
  final int? totalCount;

  DomainSearchResponse({required this.items, this.totalCount});

  factory DomainSearchResponse.fromJson(Map<String, dynamic> json) {
    return DomainSearchResponse(
      items: (json['items'] as List)
          .map((e) => SearchItemResponse.fromJson(e))
          .toList(),
      totalCount: json['totalCount'],
    );
  }
}
