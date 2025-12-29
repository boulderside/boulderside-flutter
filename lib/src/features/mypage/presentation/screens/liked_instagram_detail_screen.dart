import 'dart:convert';

import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram_detail.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_instagram_detail_use_case.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_instagram_like_use_case.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LikedInstagramDetailScreen extends StatefulWidget {
  const LikedInstagramDetailScreen({super.key, required this.instagram});

  final Instagram instagram;

  @override
  State<LikedInstagramDetailScreen> createState() =>
      _LikedInstagramDetailScreenState();
}

class _LikedInstagramDetailScreenState
    extends State<LikedInstagramDetailScreen> {
  InstagramDetail? _detail;
  WebViewController? _controller;
  TextEditingController? _urlController;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isWebViewLoading = true;
  bool _isLikeProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _urlController?.dispose();
    super.dispose();
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
        title: const Text(
          '베타 상세',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF3278)),
      );
    }

    if (_errorMessage != null || _detail == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage ?? '상세 정보를 불러오지 못했습니다.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Pretendard',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadDetail,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final detail = _detail!;
    return SafeArea(
      bottom: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final webViewHeight = (constraints.maxHeight * 0.9).clamp(
            680.0,
            980.0,
          );
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(detail),
                const SizedBox(height: 12),
                _buildHtmlSection(height: webViewHeight),
                const SizedBox(height: 20),
                _buildLinkSection(detail.url),
                const SizedBox(height: 20),
                _buildRouteSection(detail.routes),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(InstagramDetail detail) {
    final nickname = detail.userInfo.nickname.isNotEmpty
        ? detail.userInfo.nickname
        : '알 수 없음';
    final profileUrl = detail.userInfo.profileImageUrl;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2E333D)),
          ),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF262A34),
            backgroundImage: profileUrl != null && profileUrl.isNotEmpty
                ? NetworkImage(profileUrl)
                : null,
            child: profileUrl == null || profileUrl.isEmpty
                ? Text(
                    nickname.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          nickname,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Pretendard',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              Text(
                _formatDateTime(detail.createdAt),
                style: const TextStyle(
                  color: Colors.white54,
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _isLikeProcessing ? null : _toggleLike,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      detail.liked
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: detail.liked
                          ? Colors.red
                          : const Color(0xFF9498A1),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${detail.likeCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkSection(String url) {
    _urlController ??= TextEditingController(text: url);
    _urlController!.text = url;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '인스타그램 링크',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Pretendard',
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 16),
        TextField(
          controller: _urlController,
          style: const TextStyle(color: Colors.white, fontFamily: 'Pretendard'),
          textAlignVertical: TextAlignVertical.center,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'https://www.instagram.com/p/...',
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: const Color(0xFF262A34),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.instagram,
                  color: Colors.white54,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHtmlSection({required double height}) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        SizedBox(
          height: height,
          child: WebViewWidget(controller: controller),
        ),
        if (_isWebViewLoading)
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF3278)),
            ),
          ),
      ],
    );
  }

  Widget _buildRouteSection(List<InstagramRouteInfo> routes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '연결된 루트',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Pretendard',
          ),
        ),
        const SizedBox(height: 12),
        if (routes.isEmpty)
          const Text(
            '연결된 루트가 없습니다.',
            style: TextStyle(color: Colors.white54, fontFamily: 'Pretendard'),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: routes
                .map(
                  (route) => GestureDetector(
                    onTap: () => _openRouteDetail(route),
                    child: _routePill(
                      route.name,
                      textColor: Colors.white,
                      borderColor: const Color(0xFF2E333D),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _routePill(
    String text, {
    required Color textColor,
    required Color borderColor,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Pretendard',
          fontSize: 13,
        ),
      ),
    );
  }

  void _openRouteDetail(InstagramRouteInfo routeInfo) {
    final fallbackDate = _detail?.createdAt ?? DateTime.now();
    final route = RouteModel(
      id: routeInfo.routeId,
      boulderId: 0,
      province: '',
      city: '',
      name: routeInfo.name,
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
      imageInfoList: const [],
      createdAt: fallbackDate,
      updatedAt: fallbackDate,
      completed: false,
    );
    context.push(AppRoutes.routeDetail, extra: route);
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await di<FetchInstagramDetailUseCase>()(widget.instagram.id);
    result.when(
      success: (detail) {
        _detail = detail;
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0xFF181A20))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) {
                if (!mounted) return;
                setState(() => _isWebViewLoading = false);
              },
            ),
          )
          ..loadRequest(
            Uri.dataFromString(
              _buildHtml(detail.url),
              mimeType: 'text/html',
              encoding: utf8,
            ),
          );
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isWebViewLoading = true;
          });
        }
      },
      failure: (failure) {
        if (!mounted) return;
        setState(() {
          _errorMessage = failure.message;
          _isLoading = false;
        });
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$year.$month.$day $hour:$minute';
  }

  Future<void> _toggleLike() async {
    final detail = _detail;
    if (detail == null || _isLikeProcessing) return;
    setState(() {
      _isLikeProcessing = true;
      _detail = InstagramDetail(
        id: detail.id,
        url: detail.url,
        userInfo: detail.userInfo,
        routes: detail.routes,
        likeCount: detail.likeCount + (detail.liked ? -1 : 1),
        liked: !detail.liked,
        createdAt: detail.createdAt,
        updatedAt: detail.updatedAt,
      );
    });

    try {
      final result = await di<ToggleInstagramLikeUseCase>()(detail.id);
      if (!mounted) return;
      setState(() {
        _detail = InstagramDetail(
          id: detail.id,
          url: detail.url,
          userInfo: detail.userInfo,
          routes: detail.routes,
          likeCount: result.likeCount ?? detail.likeCount,
          liked: result.liked ?? !detail.liked,
          createdAt: detail.createdAt,
          updatedAt: detail.updatedAt,
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _detail = detail;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('좋아요를 변경하지 못했습니다: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isLikeProcessing = false;
        });
      }
    }
  }

  String _buildHtml(String url) {
    return '''
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <style>
    body {
      margin: 0;
      padding: 16px 8px 24px;
      background: #181A20;
    }
    .post {
      width: 100%;
      max-width: 520px;
      margin: 0 auto;
    }
    .instagram-media {
      margin: 0 !important;
      width: 100% !important;
      min-width: 0 !important;
    }
  </style>
</head>
<body>
  <div class="post">
    <blockquote
      class="instagram-media"
      data-instgrm-permalink="$url"
      data-instgrm-version="14">
    </blockquote>
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
''';
  }
}
