import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/community/data/models/comment_models.dart';
import 'package:boulderside_flutter/src/features/community/data/services/comment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentStore extends StateNotifier<CommentStoreState> {
  CommentStore(this._service) : super(const CommentStoreState());

  final CommentService _service;
  static const int _pageSize = 10;

  String _key(String domainType, int domainId) => '$domainType#$domainId';

  CommentFeedState _feed(String domainType, int domainId) {
    final key = _key(domainType, domainId);
    return state.feeds[key] ?? const CommentFeedState();
  }

  void _setFeed(String domainType, int domainId, CommentFeedState feed) {
    final key = _key(domainType, domainId);
    final feeds = Map<String, CommentFeedState>.from(state.feeds)..[key] = feed;
    state = state.copyWith(feeds: feeds);
  }

  void _upsertComments(
    String domainType,
    int domainId,
    List<CommentResponseModel> comments, {
    bool reset = false,
  }) {
    final key = _key(domainType, domainId);
    final entities = Map<String, List<CommentResponseModel>>.from(
      state.comments,
    );
    final existing = reset ? <CommentResponseModel>[] : (entities[key] ?? []);
    if (reset) {
      entities[key] = comments;
    } else {
      entities[key] = [...existing, ...comments];
    }
    state = state.copyWith(comments: entities);
  }

  Future<void> loadInitial(String domainType, int domainId) async {
    if (domainType.isEmpty || domainId == 0) return;
    final feed = _feed(domainType, domainId);
    _setFeed(
      domainType,
      domainId,
      feed.copyWith(isLoading: true, errorMessage: null),
    );
    try {
      final response = await _service.getComments(
        domainType: domainType,
        domainId: domainId,
        cursor: null,
        size: _pageSize,
      );
      _upsertComments(domainType, domainId, response.content, reset: true);
      _setFeed(
        domainType,
        domainId,
        feed.copyWith(
          nextCursor: response.nextCursor,
          hasNext: response.hasNext,
          isLoading: false,
          isLoadingMore: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      _setFeed(
        domainType,
        domainId,
        feed.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: '댓글을 불러오지 못했습니다.',
        ),
      );
    }
  }

  Future<void> loadMore(String domainType, int domainId) async {
    if (domainType.isEmpty || domainId == 0) return;
    final feed = _feed(domainType, domainId);
    if (feed.isLoading || feed.isLoadingMore || !feed.hasNext) return;

    _setFeed(
      domainType,
      domainId,
      feed.copyWith(isLoadingMore: true, errorMessage: null),
    );
    try {
      final response = await _service.getComments(
        domainType: domainType,
        domainId: domainId,
        cursor: feed.nextCursor,
        size: _pageSize,
      );
      _upsertComments(domainType, domainId, response.content);
      _setFeed(
        domainType,
        domainId,
        feed.copyWith(
          nextCursor: response.nextCursor,
          hasNext: response.hasNext,
          isLoadingMore: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      _setFeed(
        domainType,
        domainId,
        feed.copyWith(isLoadingMore: false, errorMessage: '댓글을 불러오지 못했습니다.'),
      );
    }
  }

  Future<void> addComment(
    String domainType,
    int domainId,
    String content,
  ) async {
    if (content.trim().isEmpty) return;
    try {
      _setFeed(
        domainType,
        domainId,
        _feed(domainType, domainId).copyWith(isSubmitting: true),
      );
      final result = await _service.createComment(
        domainType: domainType,
        domainId: domainId,
        content: content.trim(),
      );
      final key = _key(domainType, domainId);
      final entities = Map<String, List<CommentResponseModel>>.from(
        state.comments,
      );
      final existing = entities[key] ?? <CommentResponseModel>[];
      entities[key] = [result, ...existing];
      state = state.copyWith(comments: entities);
    } catch (error) {
      _setFeed(
        domainType,
        domainId,
        _feed(domainType, domainId).copyWith(errorMessage: '댓글을 추가하지 못했습니다.'),
      );
    } finally {
      _setFeed(
        domainType,
        domainId,
        _feed(domainType, domainId).copyWith(isSubmitting: false),
      );
    }
  }

  Future<void> editComment(
    String domainType,
    int domainId,
    int commentId,
    String content,
  ) async {
    if (content.trim().isEmpty) return;
    try {
      _setFeed(
        domainType,
        domainId,
        _feed(domainType, domainId).copyWith(isSubmitting: true),
      );
      final updated = await _service.updateComment(
        domainType: domainType,
        domainId: domainId,
        commentId: commentId,
        content: content.trim(),
      );
      final key = _key(domainType, domainId);
      final entities = Map<String, List<CommentResponseModel>>.from(
        state.comments,
      );
      final list = entities[key] ?? <CommentResponseModel>[];
      final index = list.indexWhere((item) => item.commentId == commentId);
      if (index >= 0) {
        list[index] = updated;
        entities[key] = List<CommentResponseModel>.from(list);
        state = state.copyWith(comments: entities);
      }
    } catch (error) {
      _setFeed(
        domainType,
        domainId,
        _feed(domainType, domainId).copyWith(errorMessage: '댓글을 수정하지 못했습니다.'),
      );
    } finally {
      _setFeed(
        domainType,
        domainId,
        _feed(domainType, domainId).copyWith(isSubmitting: false),
      );
    }
  }

  Future<void> deleteComment(
    String domainType,
    int domainId,
    int commentId,
  ) async {
    try {
      await _service.deleteComment(
        domainType: domainType,
        domainId: domainId,
        commentId: commentId,
      );
      final key = _key(domainType, domainId);
      final entities = Map<String, List<CommentResponseModel>>.from(
        state.comments,
      );
      final updated = (entities[key] ?? <CommentResponseModel>[])
          .where((comment) => comment.commentId != commentId)
          .toList();
      entities[key] = updated;
      state = state.copyWith(comments: entities);
    } catch (error) {
      _setFeed(
        domainType,
        domainId,
        _feed(domainType, domainId).copyWith(errorMessage: '댓글을 삭제하지 못했습니다.'),
      );
    }
  }
}

class CommentStoreState {
  const CommentStoreState({
    this.feeds = const <String, CommentFeedState>{},
    this.comments = const <String, List<CommentResponseModel>>{},
  });

  final Map<String, CommentFeedState> feeds;
  final Map<String, List<CommentResponseModel>> comments;

  CommentStoreState copyWith({
    Map<String, CommentFeedState>? feeds,
    Map<String, List<CommentResponseModel>>? comments,
  }) {
    return CommentStoreState(
      feeds: feeds ?? this.feeds,
      comments: comments ?? this.comments,
    );
  }
}

const _sentinel = Object();

class CommentFeedState {
  const CommentFeedState({
    this.nextCursor,
    this.hasNext = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final int? nextCursor;
  final bool hasNext;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSubmitting;
  final String? errorMessage;

  CommentFeedState copyWith({
    Object? nextCursor = _sentinel,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSubmitting,
    Object? errorMessage = _sentinel,
  }) {
    return CommentFeedState(
      nextCursor: identical(nextCursor, _sentinel)
          ? this.nextCursor
          : nextCursor as int?,
      hasNext: hasNext ?? this.hasNext,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class CommentFeedViewData {
  const CommentFeedViewData({
    required this.comments,
    required this.isLoading,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.isSubmitting,
    required this.hasNext,
    required this.errorMessage,
  });

  final List<CommentResponseModel> comments;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool isSubmitting;
  final bool hasNext;
  final String? errorMessage;
}

final commentServiceProvider = Provider<CommentService>(
  (ref) => di<CommentService>(),
);

final commentStoreProvider =
    StateNotifierProvider<CommentStore, CommentStoreState>((ref) {
      return CommentStore(ref.watch(commentServiceProvider));
    });

final commentFeedProvider = Provider.family<CommentFeedViewData, (String, int)>(
  (ref, key) {
    final (domainType, domainId) = key;
    final state = ref.watch(commentStoreProvider);
    final feed =
        state.feeds['$domainType#$domainId'] ?? const CommentFeedState();
    final comments =
        state.comments['$domainType#$domainId'] ??
        const <CommentResponseModel>[];
    final isInitialLoading = feed.isLoading && comments.isEmpty;
    return CommentFeedViewData(
      comments: comments,
      isLoading: feed.isLoading,
      isInitialLoading: isInitialLoading,
      isLoadingMore: feed.isLoadingMore,
      isSubmitting: feed.isSubmitting,
      hasNext: feed.hasNext,
      errorMessage: feed.errorMessage,
    );
  },
);
