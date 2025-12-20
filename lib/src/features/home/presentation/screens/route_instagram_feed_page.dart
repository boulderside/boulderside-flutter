import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RouteInstagramFeedPage extends StatefulWidget {
  final int routeId;
  final String routeName;

  const RouteInstagramFeedPage({
    super.key,
    required this.routeId,
    required this.routeName,
  });

  @override
  State<RouteInstagramFeedPage> createState() => _RouteInstagramFeedPageState();
}

class _RouteInstagramFeedPageState extends State<RouteInstagramFeedPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  // 테스트용 인스타그램 게시물 URL 목록
  final List<String> _instagramUrls = [
    'https://www.instagram.com/p/DPyGE_IkdlU/',
    'https://www.instagram.com/p/DHCxc32TQaw/',
    'https://www.instagram.com/p/DJ07RD4Oymw/?img_index=1',
    'https://www.instagram.com/p/DRge8RVkSGD/',
  ];

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final String htmlContent = _generateHtmlContent(_instagramUrls);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF181A20))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(
        Uri.dataFromString(
          htmlContent,
          mimeType: 'text/html',
          encoding: null, // utf-8
        ),
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

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF3278)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF3278),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () => _showAddInstagramPostBottomSheet(context),
      ),
    );
  }

  void _showAddInstagramPostBottomSheet(BuildContext context) {
    final TextEditingController urlController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
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
                children: [
                  Chip(
                    label: Text(widget.routeName),
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
                  ActionChip(
                    avatar: const Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.white70,
                    ),
                    label: const Text('다른 루트 추가'),
                    backgroundColor: const Color(0xFF262A34),
                    labelStyle: const TextStyle(color: Colors.white70),
                    onPressed: () {
                      // TODO: 루트 검색 및 추가 로직
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
                  onPressed: () {
                    // TODO: 서버 전송 로직
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('풀이 영상이 등록되었습니다!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3278),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
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
      ),
    );
  }
}
