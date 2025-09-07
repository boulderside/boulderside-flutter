import 'package:boulderside_flutter/home/models/boulder_model.dart';
import 'package:boulderside_flutter/home/models/route_model.dart';
import 'package:boulderside_flutter/community/models/companion_post.dart';

enum DocumentDomainType {
  boulder,
  route,
  post,
}

class AutocompleteResponse {
  final List<String> suggestionList;

  AutocompleteResponse({
    required this.suggestionList,
  });

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
    switch (type.toLowerCase()) {
      case 'boulder':
        return DocumentDomainType.boulder;
      case 'route':
        return DocumentDomainType.route;
      case 'post':
        return DocumentDomainType.post;
      default:
        throw ArgumentError('Unknown domain type: $type');
    }
  }
}

class DomainSearchResult {
  final List<SearchItemResponse> items;
  final bool hasMore;

  DomainSearchResult({
    required this.items,
    required this.hasMore,
  });

  factory DomainSearchResult.fromJson(Map<String, dynamic> json) {
    return DomainSearchResult(
      items: (json['items'] as List)
          .map((e) => SearchItemResponse.fromJson(e))
          .toList(),
      hasMore: json['hasMore'],
    );
  }
}

class SearchItemResponse {
  final String id;
  final String title;
  final DocumentDomainType domainType;
  final String? thumbnailUrl;
  final String? province;
  final String? city;
  final String? level;
  final String? authorName;
  final int? viewCount;
  final int? commentCount;
  final int? likeCount;
  final int? climberCount;
  final DateTime? meetingDate;
  final DateTime? createdAt;

  SearchItemResponse({
    required this.id,
    required this.title,
    required this.domainType,
    this.thumbnailUrl,
    this.province,
    this.city,
    this.level,
    this.authorName,
    this.viewCount,
    this.commentCount,
    this.likeCount,
    this.climberCount,
    this.meetingDate,
    this.createdAt,
  });

  factory SearchItemResponse.fromJson(Map<String, dynamic> json) {
    return SearchItemResponse(
      id: json['id'],
      title: json['title'],
      domainType: UnifiedSearchResponse._parseDomainType(json['domainType']),
      thumbnailUrl: json['thumbnailUrl'],
      province: json['province'],
      city: json['city'],
      level: json['level'],
      authorName: json['authorName'],
      viewCount: json['viewCount'],
      commentCount: json['commentCount'],
      likeCount: json['likeCount'],
      climberCount: json['climberCount'],
      meetingDate: json['meetingDate'] != null 
          ? DateTime.parse(json['meetingDate']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  // Convert to existing model types for compatibility
  BoulderModel toBoulderModel() {
    return BoulderModel(
      id: int.parse(id),
      name: title,
      description: '', // Default empty description
      latitude: 0.0, // Default latitude
      longitude: 0.0, // Default longitude
      province: province ?? '',
      city: city ?? '',
      likeCount: likeCount ?? 0,
      imageInfoList: [], // Default empty image list
      liked: false, // Default value
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: createdAt ?? DateTime.now(),
    );
  }

  RouteModel toRouteModel() {
    return RouteModel(
      id: int.parse(id),
      name: title,
      routeLevel: level ?? '',
      likes: likeCount ?? 0,
      isLiked: false, // Default value
      climbers: climberCount ?? 0,
    );
  }

  CompanionPost toCompanionPost() {
    return CompanionPost(
      id: int.parse(id),
      title: title,
      meetingPlace: city ?? province ?? '',
      meetingDateLabel: meetingDate != null 
          ? '${meetingDate!.year}.${meetingDate!.month.toString().padLeft(2, '0')}.${meetingDate!.day.toString().padLeft(2, '0')}'
          : '',
      authorNickname: authorName ?? '',
      commentCount: commentCount ?? 0,
      viewCount: viewCount ?? 0,
      createdAt: createdAt ?? DateTime.now(),
      content: null, // Not available in search response
    );
  }
}

class DomainSearchResponse {
  final List<SearchItemResponse> items;
  final int? totalCount;

  DomainSearchResponse({
    required this.items,
    this.totalCount,
  });

  factory DomainSearchResponse.fromJson(Map<String, dynamic> json) {
    return DomainSearchResponse(
      items: (json['items'] as List)
          .map((e) => SearchItemResponse.fromJson(e))
          .toList(),
      totalCount: json['totalCount'],
    );
  }
}