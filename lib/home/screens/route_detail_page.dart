import 'package:boulderside_flutter/community/widgets/comment_list.dart';
import 'package:boulderside_flutter/home/models/image_info_model.dart';
import 'package:boulderside_flutter/home/models/route_detail_model.dart';
import 'package:boulderside_flutter/home/models/route_model.dart';
import 'package:boulderside_flutter/home/services/route_detail_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RouteDetailPage extends StatefulWidget {
  final RouteModel route;

  const RouteDetailPage({super.key, required this.route});

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  final RouteDetailService _service = RouteDetailService();
  final Color _backgroundColor = const Color(0xFF181A20);
  final Color _cardColor = const Color(0xFF262A34);

  RouteDetailModel? _detail;
  bool _isLoading = true;
  String? _errorMessage;

  late final PageController _pageController;
  int _currentImageIndex = 0;
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _isLiked = widget.route.isLiked;
    _likeCount = widget.route.likes;
    _fetchDetail();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _service.fetchDetail(widget.route.id);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _isLiked = detail.route.isLiked;
        _likeCount = detail.route.likes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '루트 정보를 불러오지 못했습니다.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('루트 정보를 불러오지 못했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    // TODO: 좋아요 API 연동
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '루트 상세',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
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

    if (_detail == null && _errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDetail,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final detail = _detail;
    final route = detail?.route ?? widget.route;
    final images = detail?.images ?? <ImageInfoModel>[];
    final description = (detail?.description ?? '').trim().isEmpty
        ? '루트 설명이 아직 등록되지 않았습니다.'
        : detail!.description!.trim();
    final location = detail?.location ?? '';

    final screenHeight = MediaQuery.of(context).size.height;

    return RefreshIndicator(
      onRefresh: _fetchDetail,
      color: const Color(0xFFFF3278),
      backgroundColor: _cardColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageCarousel(images),
            _buildHeader(route, location, detail?.boulderName),
            _buildDescription(description),
            const SizedBox(height: 20),
            SizedBox(
              height: screenHeight * 0.9,
              child: CommentList(
                domainType: 'routes',
                domainId: route.id,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List<ImageInfoModel> images) {
    if (images.isEmpty) {
      return Container(
        height: 260,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            CupertinoIcons.photo,
            size: 48,
            color: Colors.white54,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            SizedBox(
              height: 360,
              child: GestureDetector(
                onTap: () => _openImageViewer(images, _currentImageIndex),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return Image.network(
                      image.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: const Color(0xFF2F3440),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF3278),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, _, __) {
                        return Container(
                          color: const Color(0xFF2F3440),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.exclamationmark_triangle,
                              color: Colors.white54,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${images.length}',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImageViewer(List<ImageInfoModel> images, int initialIndex) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      pageBuilder: (context, _, __) {
        return _RouteImageViewer(
          images: images,
          initialIndex: initialIndex,
        );
      },
    );
  }

  Widget _buildHeader(
    RouteModel route,
    String location,
    String? boulderName,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            route.name,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3278).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  route.routeLevel,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _MiniMetric(
                      icon: _isLiked
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      value: _likeCount,
                      color: _isLiked ? Colors.red : Colors.white70,
                      onTap: _toggleLike,
                    ),
                    const SizedBox(width: 12),
                    _MiniMetric(
                      icon: CupertinoIcons.eye,
                      value: route.viewCount,
                    ),
                    const SizedBox(width: 12),
                    _MiniMetric(
                      icon: CupertinoIcons.person_2_fill,
                      value: route.climberCount,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (boulderName != null && boulderName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              boulderName,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
          if (location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  CupertinoIcons.location_solid,
                  size: 18,
                  color: Color(0xFF7C7C7C),
                ),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '루트 설명',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color? color;
  final VoidCallback? onTap;

  const _MiniMetric({
    required this.icon,
    required this.value,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? Colors.white70,
        ),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    if (onTap == null) {
      return content;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}

class _RouteImageViewer extends StatefulWidget {
  final List<ImageInfoModel> images;
  final int initialIndex;

  const _RouteImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_RouteImageViewer> createState() => _RouteImageViewerState();
}

class _RouteImageViewerState extends State<_RouteImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final image = widget.images[index];
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      image.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white70,
                          ),
                        );
                      },
                      errorBuilder: (context, _, __) {
                        return const Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          color: Colors.white54,
                          size: 40,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Colors.white70,
                  size: 32,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.images.length}',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
