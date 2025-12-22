import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/application/route_instagram_store.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/create_instagram_use_case.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_search_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  late final WebViewController _controller;
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
        onPressed: () => _showAddInstagramPostBottomSheet(context),
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
          WebViewWidget(controller: _controller),
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

  void _showAddInstagramPostBottomSheet(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    final List<RouteModel> selectedRoutes = [
      RouteModel(
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
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E2129),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '내 풀이 등록하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '인스타그램 게시글 링크를 입력해주세요.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: urlController,
                      style: const TextStyle(color: Colors.white),
                      enabled: !isSubmitting,
                      decoration: InputDecoration(
                        hintText: 'https://www.instagram.com/p/...',
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: const Color(0xFF262A34),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: FaIcon(
                            FontAwesomeIcons.instagram,
                            color: Colors.white54,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '연결된 루트',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...selectedRoutes.map(
                          (route) => Chip(
                            label: Text(route.name),
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFFFF3278),
                            ),
                            onDeleted: selectedRoutes.length > 1
                                ? () {
                                    setModalState(() {
                                      selectedRoutes.remove(route);
                                    });
                                  }
                                : null,
                            backgroundColor: const Color(
                              0xFFFF3278,
                            ).withValues(alpha: 0.2),
                            labelStyle: const TextStyle(
                              color: Color(0xFFFF3278),
                              fontWeight: FontWeight.bold,
                            ),
                            side: const BorderSide(color: Color(0xFFFF3278)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white70,
                          ),
                          label: const Text('다른 루트 추가'),
                          backgroundColor: const Color(0xFF262A34),
                          labelStyle: const TextStyle(color: Colors.white70),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final selected =
                                      await showModalBottomSheet<RouteModel>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            RouteSearchBottomSheet(
                                              alreadySelected: selectedRoutes,
                                            ),
                                      );
                                  if (selected != null) {
                                    setModalState(() {
                                      if (!selectedRoutes.any(
                                        (r) => r.id == selected.id,
                                      )) {
                                        selectedRoutes.add(selected);
                                      }
                                    });
                                  }
                                },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final url = urlController.text.trim();
                                if (url.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('인스타그램 링크를 입력해주세요.'),
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() => isSubmitting = true);

                                try {
                                  await di<CreateInstagramUseCase>().execute(
                                    url: url,
                                    routeIds: selectedRoutes
                                        .map((r) => r.id)
                                        .toList(),
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('풀이 영상이 등록되었습니다!'),
                                      ),
                                    );
                                    // Refresh the feed
                                    _onRefresh();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    setModalState(() => isSubmitting = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('등록 실패: ${e.toString()}'),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3278),
                          disabledBackgroundColor: const Color(
                            0xFFFF3278,
                          ).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                '등록 완료',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
