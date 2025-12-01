import 'package:boulderside_flutter/src/features/home/data/models/boulder_model.dart';
import 'package:boulderside_flutter/src/features/home/data/models/image_info_model.dart';
import 'package:boulderside_flutter/src/features/home/data/models/route_model.dart';
import 'package:boulderside_flutter/src/features/community/data/models/companion_post.dart';

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
  final String? sectorName;
  final String? areaCode;
  final String? pioneerName;
  final double? latitude;
  final double? longitude;
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
    this.sectorName,
    this.areaCode,
    this.pioneerName,
    this.latitude,
    this.longitude,
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
      sectorName: json['sectorName'],
      areaCode: json['areaCode'],
      pioneerName: json['pioneerName'],
      latitude: _toNullableDouble(json['latitude']),
      longitude: _toNullableDouble(json['longitude']),
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
    final List<ImageInfoModel> images =
        thumbnailUrl != null && thumbnailUrl!.isNotEmpty
            ? [
                ImageInfoModel(
                  targetType: 'BOULDER',
                  imageUrl: thumbnailUrl!,
                  orderIndex: 0,
                ),
              ]
            : <ImageInfoModel>[];
    return BoulderModel(
      id: int.parse(id),
      name: title,
      description: '', // Default empty description
      sectorName: sectorName ?? '',
      areaCode: areaCode ?? '',
      latitude: 0.0, // Default latitude
      longitude: 0.0, // Default longitude
      province: province ?? '',
      city: city ?? '',
      likeCount: likeCount ?? 0,
      viewCount: viewCount ?? 0,
      imageInfoList: images,
      liked: false, // Default value
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: createdAt ?? DateTime.now(),
    );
  }

  RouteModel toRouteModel() {
    final List<ImageInfoModel> images =
        thumbnailUrl != null && thumbnailUrl!.isNotEmpty
            ? [
                ImageInfoModel(
                  targetType: 'ROUTE',
                  imageUrl: thumbnailUrl!,
                  orderIndex: 0,
                ),
              ]
            : <ImageInfoModel>[];
    return RouteModel(
      id: int.parse(id),
      boulderId: 0, // Default value for search results
      province: province ?? '',
      city: city ?? '',
      name: title,
      pioneerName: pioneerName ?? '',
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      sectorName: sectorName ?? '',
      areaCode: areaCode ?? '',
      routeLevel: level ?? '',
      likeCount: likeCount ?? 0,
      liked: false, // Default value
      viewCount: viewCount ?? 0,
      climberCount: climberCount ?? 0,
      commentCount: commentCount ?? 0,
      imageInfoList: images,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: createdAt ?? DateTime.now(),
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

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
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
