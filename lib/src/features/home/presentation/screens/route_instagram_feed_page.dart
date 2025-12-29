import 'dart:convert';

import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/home/application/route_instagram_store.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/route_instagram.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_instagram_like_use_case.dart';
import 'package:boulderside_flutter/src/features/home/presentation/screens/route_instagram_create_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/cupertino.dart';

class RouteInstagramFeedPage extends ConsumerStatefulWidget {
  final int routeId;
  final String routeName;

  const RouteInstagramFeedPage({
    super.key,
    required this.routeId,
    required this.routeName,
  });

  @override
  ConsumerState<RouteInstagramFeedPage> createState() =>
      _RouteInstagramFeedPageState();
}

class _RouteInstagramFeedPageState
    extends ConsumerState<RouteInstagramFeedPage> {
  WebViewController? _controller;
  bool _isWebViewLoading = true;
  final ScrollController _scrollController = ScrollController();
  final Set<int> _likeProcessing = <int>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(routeInstagramStoreProvider(widget.routeId).notifier)
          .loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final feed = ref.read(routeInstagramFeedProvider(widget.routeId));
      if (feed.hasNext && !feed.isLoadingMore) {
        ref
            .read(routeInstagramStoreProvider(widget.routeId).notifier)
            .loadMore();
      }
    }
  }

  void _initWebView(List<RouteInstagram> items) {
    _isWebViewLoading = true;
    final String htmlContent = _generateHtmlContent(items);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF181A20))
      ..addJavaScriptChannel(
        'InstagramLike',
        onMessageReceived: (message) => _handleLikeMessage(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isWebViewLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(
        Uri.dataFromString(htmlContent, mimeType: 'text/html', encoding: utf8),
      );
  }

  String _generateHtmlContent(List<RouteInstagram> items) {
    final sb = StringBuffer();
    sb.write('''
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <style>
    body {
      margin: 0;
      padding: 8px;
      background: #181A20;
    }
    .feed {
      display: flex;
      flex-direction: column;
      gap: 32px;
      align-items: center;
    }
    .post {
      width: 100%;
      max-width: 500px;
    }
    .post-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 4px 2px 10px;
      color: #ffffff;
    }
    .author {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      min-width: 0;
    }
    .avatar {
      width: 28px;
      height: 28px;
      border-radius: 50%;
      object-fit: cover;
      background: #262A34;
      border: 1px solid #2E333D;
      flex-shrink: 0;
    }
    .author-text {
      display: flex;
      align-items: center;
      gap: 8px;
      min-width: 0;
    }
    .nickname {
      color: #ffffff;
      font-size: 13px;
      font-weight: 700;
      line-height: 1.2;
      white-space: nowrap;
    }
    .created {
      color: #9aa0ac;
      font-size: 12px;
      white-space: nowrap;
    }
    .instagram-media {
      margin: 0 !important;
      width: 100% !important;
      min-width: 0 !important;
    }
    .like-button {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      border: 0;
      padding: 0;
      background: transparent;
      color: #9498a1;
      font-size: 17px;
      font-weight: 400;
      font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI',
        sans-serif;
      cursor: pointer;
    }
    .like-button.liked {
      color: #ff3278;
    }
    .like-button .heart {
      font-size: 22px;
      line-height: 1;
    }
    .like-button .count {
      color: #ffffff;
    }
  </style>
</head>
<body>
  <div class="feed">
    ''');

    for (var item in items) {
      final instagram = item.instagram;
      final nickname = instagram.userInfo?.nickname ?? '';
      final profileUrl = instagram.userInfo?.profileImageUrl ?? '';
      final createdAt = _formatDateTime(instagram.createdAt);
      sb.write('''
    <div class="post">
      <div class="post-header">
        <div class="author">
          ${profileUrl.isNotEmpty ? '<img class="avatar" src="$profileUrl" />' : '<div class="avatar"></div>'}
          <div class="author-text">
            <div class="nickname">${nickname.isNotEmpty ? nickname : '알 수 없음'}</div>
            <div class="created">$createdAt</div>
          </div>
        </div>
        <button
          class="like-button${instagram.liked ? ' liked' : ''}"
          type="button"
          data-instagram-id="${instagram.id}"
          data-liked="${instagram.liked}">
          <span class="heart">${instagram.liked ? '♥' : '♡'}</span>
          <span class="count">${instagram.likeCount}</span>
        </button>
      </div>
      <blockquote
        class="instagram-media"
        data-instgrm-permalink="${instagram.url}"
        data-instgrm-version="14">
      </blockquote>
    </div>
      ''');
    }

    sb.write('''
  </div>
  <script async defer src="https://platform.instagram.com/en_US/embeds.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      if (window.instgrm) {
        window.instgrm.Embeds.process();
      }
    });
    function updateLikeButton(instagramId, liked, likeCount) {
      const button = document.querySelector(
        '.like-button[data-instagram-id="' + instagramId + '"]'
      );
      if (!button) return;
      if (liked) {
        button.classList.add("liked");
      } else {
        button.classList.remove("liked");
      }
      button.setAttribute("data-liked", String(liked));
      const heartNode = button.querySelector(".heart");
      if (heartNode) {
        heartNode.textContent = liked ? "♥" : "♡";
      }
      const countNode = button.querySelector(".count");
      if (countNode) {
        countNode.textContent = String(likeCount);
      }
    }
    document.addEventListener("click", function (event) {
      const button = event.target.closest(".like-button");
      if (!button) return;
      const instagramId = button.getAttribute("data-instagram-id");
      if (!instagramId || !window.InstagramLike) return;
      window.InstagramLike.postMessage(
        JSON.stringify({ instagramId: Number(instagramId) })
      );
    });
  </script>
</body>
</html>
    ''');

    return sb.toString();
  }

  Future<void> _onRefresh() async {
    await ref
        .read(routeInstagramStoreProvider(widget.routeId).notifier)
        .refresh();
    // Reload WebView with new data
    final feed = ref.read(routeInstagramFeedProvider(widget.routeId));
    if (feed.items.isNotEmpty) {
      _initWebView(feed.items);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(routeInstagramFeedProvider(widget.routeId));

    // Initialize WebView when items are loaded
    if (feed.items.isNotEmpty && _isWebViewLoading) {
      _initWebView(feed.items);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.routeName} 풀이 영상',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: _buildBody(feed),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF3278),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () => _openAddInstagramPostPage(context),
      ),
    );
  }

  Widget _buildBody(RouteInstagramFeedViewData feed) {
    // Initial loading
    if (feed.isInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF3278)),
      );
    }

    // Error with no items
    if (feed.errorMessage != null && feed.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              feed.errorMessage!,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Pretendard',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(routeInstagramStoreProvider(widget.routeId).notifier)
                  .loadInitial(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3278),
              ),
              child: const Text(
                '다시 시도',
                style: TextStyle(color: Colors.white, fontFamily: 'Pretendard'),
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (feed.items.isEmpty) {
      return const Center(
        child: Text(
          '등록된 풀이 영상이 없습니다.',
          style: TextStyle(
            color: Colors.white70,
            fontFamily: 'Pretendard',
            fontSize: 16,
          ),
        ),
      );
    }

    // Content with WebView
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFFFF3278),
      child: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          if (_isWebViewLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF3278)),
            ),
          if (feed.isLoadingMore)
            const Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF3278)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openAddInstagramPostPage(BuildContext context) async {
    final initialRoute = RouteModel(
      id: widget.routeId,
      boulderId: 0,
      province: '',
      city: '',
      name: widget.routeName,
      pioneerName: '',
      latitude: 0.0,
      longitude: 0.0,
      sectorName: '',
      areaCode: '',
      routeLevel: '',
      boulderName: null,
      likeCount: 0,
      liked: false,
      viewCount: 0,
      climberCount: 0,
      commentCount: 0,
      imageInfoList: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      completed: false,
    );
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            RouteInstagramCreatePage(initialRoute: initialRoute),
      ),
    );
    if (!context.mounted || created != true) return;
    await _onRefresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('풀이 영상이 등록되었습니다!')));
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$year.$month.$day $hour:$minute';
  }

  Future<void> _handleLikeMessage(String rawMessage) async {
    final parsed = jsonDecode(rawMessage);
    if (parsed is! Map<String, dynamic>) {
      return;
    }
    final idValue = parsed['instagramId'];
    if (idValue is! num) {
      return;
    }
    final instagramId = idValue.toInt();
    if (_likeProcessing.contains(instagramId)) {
      return;
    }
    final feed = ref.read(routeInstagramFeedProvider(widget.routeId));
    final target = feed.items.cast<RouteInstagram?>().firstWhere(
      (item) => item?.instagram.id == instagramId,
      orElse: () => null,
    );
    if (target == null) return;
    _likeProcessing.add(instagramId);

    final current = target.instagram;
    final optimisticLiked = !current.liked;
    final optimisticCount = current.likeCount + (optimisticLiked ? 1 : -1);
    final notifier = ref.read(
      routeInstagramStoreProvider(widget.routeId).notifier,
    );
    notifier.applyLikeResult(
      LikeToggleResult(
        instagramId: instagramId,
        liked: optimisticLiked,
        likeCount: optimisticCount,
      ),
    );
    await _updateLikeButton(instagramId, optimisticLiked, optimisticCount);

    try {
      final toggle = di<ToggleInstagramLikeUseCase>();
      final result = await toggle(instagramId);
      notifier.applyLikeResult(result);
      await _updateLikeButton(
        instagramId,
        result.liked ?? optimisticLiked,
        result.likeCount ?? optimisticCount,
      );
    } catch (error) {
      notifier.applyLikeResult(
        LikeToggleResult(
          instagramId: instagramId,
          liked: current.liked,
          likeCount: current.likeCount,
        ),
      );
      await _updateLikeButton(instagramId, current.liked, current.likeCount);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('좋아요를 변경하지 못했습니다: $error')));
      }
    } finally {
      _likeProcessing.remove(instagramId);
    }
  }

  Future<void> _updateLikeButton(
    int instagramId,
    bool liked,
    int likeCount,
  ) async {
    final controller = _controller;
    if (controller == null) return;
    await controller.runJavaScript(
      'updateLikeButton($instagramId, ${liked ? 'true' : 'false'}, $likeCount);',
    );
  }
}
