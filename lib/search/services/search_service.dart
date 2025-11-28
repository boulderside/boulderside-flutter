import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:boulderside_flutter/search/models/search_models.dart';
import 'package:dio/dio.dart';

class SearchService {
  SearchService() : _dio = ApiClient.dio;
  final Dio _dio;

  Future<AutocompleteResponse> getSuggestions(String keyword) async {
    final response = await _dio.get(
      '/search/suggest',
      queryParameters: {
        'keyword': keyword,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return AutocompleteResponse.fromJson(data);
    } else {
      throw Exception('자동완성 API 호출 실패');
    }
  }

  Future<UnifiedSearchResponse> searchUnified(String keyword) async {
    final response = await _dio.get(
      '/search/unified',
      queryParameters: {
        'keyword': keyword,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return UnifiedSearchResponse.fromJson(data);
    } else {
      throw Exception('통합 검색 API 호출 실패');
    }
  }

  Future<DomainSearchResponse> searchByDomain({
    required String keyword,
    required DocumentDomainType domain,
    int size = 10,
  }) async {
    final queryParams = {
      'keyword': keyword,
      'domain': domain.name.toUpperCase(),
      'size': size,
    };

    final response = await _dio.get(
      '/search/domain',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return DomainSearchResponse.fromJson(data);
    } else {
      throw Exception('도메인 검색 API 호출 실패');
    }
  }
}