import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/application/route_instagram_store.dart';
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

  void _initWebView(List<String> urls) {
    final String htmlContent = _generateHtmlContent(urls);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF181A20))
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
        Uri.dataFromString(htmlContent, mimeType: 'text/html', encoding: null),
      );
  }

  String _generateHtmlContent(List<String> urls) {
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
      gap: 12px;
      align-items: center;
    }
    .post {
      width: 100%;
      max-width: 500px;
    }
    .instagram-media {
      margin: 0 !important;
      width: 100% !important;
      min-width: 0 !important;
    }
  </style>
</head>
<body>
  <div class="feed">
    ''');

    for (var url in urls) {
      sb.write('''
    <div class="post">
      <blockquote
        class="instagram-media"
        data-instgrm-permalink="$url"
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
      final urls = feed.items.map((item) => item.instagram.url).toList();
      _initWebView(urls);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(routeInstagramFeedProvider(widget.routeId));

    // Initialize WebView when items are loaded
    if (feed.items.isNotEmpty && _isWebViewLoading) {
      final urls = feed.items.map((item) => item.instagram.url).toList();
      _initWebView(urls);
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
}
