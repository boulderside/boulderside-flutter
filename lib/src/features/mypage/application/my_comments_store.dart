import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/community/data/models/comment_models.dart';
import 'package:boulderside_flutter/src/features/community/data/services/comment_service.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_my_comments_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyCommentsStore extends StateNotifier<MyCommentsState> {
  MyCommentsStore(this._fetchMyComments, this._commentService)
    : super(const MyCommentsState());

  final FetchMyCommentsUseCase _fetchMyComments;
  final CommentService _commentService;

  static const int _pageSize = 10;

  Future<void> loadInitial() async {
    final feed = state.feed;
    if (feed.isLoading) return;
    _setFeed(
      feed.copyWith(isLoading: true, isLoadingMore: false, errorMessage: null),
    );
    final result = await _fetchMyComments(cursor: null, size: _pageSize);
    result.when(
      success: (page) {
        _upsert(page.items, reset: true);
        _setFeed(
          state.feed.copyWith(
            ids: page.items.map((e) => e.commentId).toList(),
            nextCursor: page.nextCursor,
            hasNext: page.hasNext,
            isLoading: false,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
      failure: (failure) {
        _setFeed(
          state.feed.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  Future<void> loadMore() async {
    final feed = state.feed;
    if (feed.isLoading || feed.isLoadingMore || !feed.hasNext) return;
    _setFeed(feed.copyWith(isLoadingMore: true, errorMessage: null));
    final result = await _fetchMyComments(
      cursor: feed.nextCursor,
      size: _pageSize,
    );
    result.when(
      success: (page) {
        _upsert(page.items, reset: false);
        _setFeed(
          state.feed.copyWith(
            ids: _mergeIds(state.feed.ids, page.items),
            nextCursor: page.nextCursor,
            hasNext: page.hasNext,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
      failure: (failure) {
        _setFeed(
          state.feed.copyWith(
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  Future<void> refresh() => loadInitial();

  Future<bool> deleteComment(CommentResponseModel comment) async {
    final previousState = state;
    _removeComment(comment.commentId);
    try {
      await _commentService.deleteComment(
        domainType: comment.commentDomainType.apiPath,
        domainId: comment.domainId,
        commentId: comment.commentId,
      );
      return true;
    } catch (_) {
      state = previousState;
      return false;
    }
  }

  void _upsert(List<CommentResponseModel> comments, {required bool reset}) {
    if (comments.isEmpty) return;
    final entities = reset
        ? <int, CommentResponseModel>{}
        : Map<int, CommentResponseModel>.from(state.entities);
    for (final comment in comments) {
      entities[comment.commentId] = comment;
    }
    state = state.copyWith(entities: entities);
  }

  void _removeComment(int commentId) {
    final entities = Map<int, CommentResponseModel>.from(state.entities)
      ..remove(commentId);
    _setFeed(state.feed.removeId(commentId));
    state = state.copyWith(entities: entities);
  }

  void _setFeed(MyCommentsFeedState feed) {
    state = state.copyWith(feed: feed);
  }

  List<int> _mergeIds(List<int> existing, List<CommentResponseModel> comments) {
    final ids = List<int>.from(existing);
    final seen = existing.toSet();
    for (final comment in comments) {
      if (seen.add(comment.commentId)) {
        ids.add(comment.commentId);
      }
    }
    return ids;
  }
}

class MyCommentsState {
  const MyCommentsState({
    this.entities = const <int, CommentResponseModel>{},
    this.feed = const MyCommentsFeedState(),
  });

  final Map<int, CommentResponseModel> entities;
  final MyCommentsFeedState feed;

  MyCommentsState copyWith({
    Map<int, CommentResponseModel>? entities,
    MyCommentsFeedState? feed,
  }) {
    return MyCommentsState(
      entities: entities ?? this.entities,
      feed: feed ?? this.feed,
    );
  }
}

class MyCommentsFeedState {
  const MyCommentsFeedState({
    this.ids = const [],
    this.nextCursor,
    this.hasNext = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<int> ids;
  final int? nextCursor;
  final bool hasNext;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  MyCommentsFeedState copyWith({
    List<int>? ids,
    Object? nextCursor = _sentinel,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return MyCommentsFeedState(
      ids: ids ?? this.ids,
      nextCursor: identical(nextCursor, _sentinel)
          ? this.nextCursor
          : nextCursor as int?,
      hasNext: hasNext ?? this.hasNext,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  MyCommentsFeedState removeId(int id) {
    final updatedIds = ids.where((existing) => existing != id).toList();
    return copyWith(ids: updatedIds);
  }
}

class MyCommentsViewData {
  const MyCommentsViewData({
    required this.items,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasNext,
    required this.errorMessage,
  });

  final List<CommentResponseModel> items;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final String? errorMessage;
}

const _sentinel = Object();

final fetchMyCommentsUseCaseProvider = Provider<FetchMyCommentsUseCase>(
  (ref) => di<FetchMyCommentsUseCase>(),
);

final commentServiceProvider = Provider<CommentService>((ref) => di());

final myCommentsStoreProvider =
    StateNotifierProvider<MyCommentsStore, MyCommentsState>((ref) {
      final fetchUseCase = ref.watch(fetchMyCommentsUseCaseProvider);
      final commentService = ref.watch(commentServiceProvider);
      return MyCommentsStore(fetchUseCase, commentService);
    });

final myCommentsFeedProvider = Provider<MyCommentsViewData>((ref) {
  final state = ref.watch(myCommentsStoreProvider);
  final feed = state.feed;
  final items = feed.ids
      .map((id) => state.entities[id])
      .whereType<CommentResponseModel>()
      .toList();
  final isInitialLoading = feed.isLoading && items.isEmpty;
  return MyCommentsViewData(
    items: items,
    isInitialLoading: isInitialLoading,
    isLoadingMore: feed.isLoadingMore,
    hasNext: feed.hasNext,
    errorMessage: feed.errorMessage,
  );
});
