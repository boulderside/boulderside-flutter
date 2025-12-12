import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/comment_list.dart';
import 'package:boulderside_flutter/src/domain/entities/image_info_model.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_route_like_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_store.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_routes_screen.dart';
import 'package:boulderside_flutter/src/features/route/application/route_store.dart';
import 'package:boulderside_flutter/src/shared/navigation/gallery_route_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouteDetailPage extends ConsumerStatefulWidget {
  final RouteModel route;

  const RouteDetailPage({super.key, required this.route});

  @override
  ConsumerState<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends ConsumerState<RouteDetailPage> {
  late final ToggleRouteLikeUseCase _toggleRouteLike;
  final Color _backgroundColor = const Color(0xFF181A20);
  final Color _cardColor = const Color(0xFF262A34);

  late final PageController _pageController;
  int _currentImageIndex = 0;
  bool _isTogglingLike = false;

  @override
  void initState() {
    super.initState();
    _toggleRouteLike = di<ToggleRouteLikeUseCase>();
    _pageController = PageController();
    final cachedDetail = ref.read(routeDetailProvider(widget.route.id)).detail;
    if (cachedDetail == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchDetail();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail({bool force = false}) async {
    try {
      await ref
          .read(routeStoreProvider.notifier)
          .fetchDetail(widget.route.id, force: force);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('루트 정보를 불러오지 못했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleLike() async {
    if (_isTogglingLike) return;
    final routeState =
        ref.read(routeEntityProvider(widget.route.id)) ?? widget.route;
    final previousLiked = routeState.liked;
    final previousCount = routeState.likeCount;
    final optimisticLiked = !previousLiked;
    final optimisticCount = previousCount + (optimisticLiked ? 1 : -1);
    setState(() {
      _isTogglingLike = true;
    });
    final notifier = ref.read(routeStoreProvider.notifier);
    notifier.applyLikeResult(
      LikeToggleResult(
        routeId: routeState.id,
        liked: optimisticLiked,
        likeCount: optimisticCount,
      ),
    );
    try {
      final result = await _toggleRouteLike(widget.route.id);
      if (!mounted) return;
      notifier.applyLikeResult(result);
    } catch (e) {
      notifier.applyLikeResult(
        LikeToggleResult(
          routeId: routeState.id,
          liked: previousLiked,
          likeCount: previousCount,
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('좋아요를 변경하지 못했습니다: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingLike = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          final didChange = _hasRouteChanged();
          context.pop(result ?? didChange);
        }
      },
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: _backgroundColor,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () {
              final didChange = _hasRouteChanged();
              context.pop(didChange);
            },
          ),
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
          actions: [
            IconButton(
              tooltip: '프로젝트 담기',
              icon: const Icon(CupertinoIcons.plus, color: Colors.white),
              onPressed: () => _openProjectForm(context),
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  ProjectModel? _findExistingProject(int routeId) {
    final projects = ref.read(projectStoreProvider).projects;
    for (final project in projects) {
      if (project.routeId == routeId) {
        return project;
      }
    }
    return null;
  }

  Future<void> _openProjectForm(BuildContext context) async {
    final store = ref.read(projectStoreProvider.notifier);
    await store.ensureRouteIndexLoaded();
    if (!mounted || !context.mounted) return;
    final route =
        ref.read(routeEntityProvider(widget.route.id)) ?? widget.route;
    final existing = _findExistingProject(widget.route.id);
    if (existing != null) {
      final action = await _showExistingProjectDialog(context);
      if (!mounted || !context.mounted) return;
      switch (action) {
        case _ExistingProjectAction.viewList:
          context.push(AppRoutes.myRoutes);
          return;
        case _ExistingProjectAction.edit:
          await _showProjectForm(context, completion: existing);
          return;
        case _ExistingProjectAction.cancel:
        case null:
          return;
      }
    }

    if (!mounted || !context.mounted) return;
    await _showProjectForm(context, initialRoute: route);
  }

  Future<void> _showProjectForm(
    BuildContext context, {
    ProjectModel? completion,
    RouteModel? initialRoute,
  }) async {
    if (!mounted) return;
    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ProjectFormSheet(completion: completion, initialRoute: initialRoute),
    );
    if (!mounted || !context.mounted) return;
    if (saved == true) {
      final message = completion == null ? '프로젝트에 추가했어요.' : '프로젝트를 수정했어요.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<_ExistingProjectAction?> _showExistingProjectDialog(
    BuildContext context,
  ) {
    return showDialog<_ExistingProjectAction>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262A34),
          title: const Text(
            '이미 등록된 루트',
            style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
          ),
          content: const Text(
            '이미 프로젝트에 등록된 루트입니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  dialogContext.pop(_ExistingProjectAction.viewList),
              child: const Text(
                '프로젝트 목록으로',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            TextButton(
              onPressed: () => dialogContext.pop(_ExistingProjectAction.edit),
              child: const Text(
                '프로젝트 수정하기',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            TextButton(
              onPressed: () => dialogContext.pop(_ExistingProjectAction.cancel),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    final detailState = ref.watch(routeDetailProvider(widget.route.id));
    if (detailState.isLoading && detailState.detail == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF3278)),
      );
    }

    if (detailState.detail == null && detailState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              detailState.errorMessage!,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchDetail, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    final detail = detailState.detail;
    final route =
        ref.watch(routeEntityProvider(widget.route.id)) ?? widget.route;
    final List<ImageInfoModel> images = detail?.images.isNotEmpty == true
        ? detail!.images
        : route.imageInfoList;
    final description = (detail?.description ?? '').trim().isEmpty
        ? '루트 설명이 아직 등록되지 않았습니다.'
        : detail!.description!.trim();
    final location = detail?.location ?? '';
    final connectedBoulder = detail?.connectedBoulder;
    final connectedBoulderName =
        (connectedBoulder?.name ?? detail?.boulderName ?? '').trim();

    final screenHeight = MediaQuery.of(context).size.height;

    return RefreshIndicator(
      onRefresh: () => _fetchDetail(force: true),
      color: const Color(0xFFFF3278),
      backgroundColor: _cardColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageCarousel(images),
            _buildHeader(
              route,
              location,
              connectedBoulder,
              connectedBoulderName.isEmpty ? null : connectedBoulderName,
            ),
            _buildDescription(description),
            const SizedBox(height: 20),
            SizedBox(
              height: screenHeight * 0.9,
              child: CommentList(domainType: 'routes', domainId: route.id),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasRouteChanged() {
    final latest =
        ref.read(routeEntityProvider(widget.route.id)) ?? widget.route;
    return latest.isLiked != widget.route.isLiked ||
        latest.likes != widget.route.likes;
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
          child: Icon(CupertinoIcons.photo, size: 48, color: Colors.white54),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
    if (images.isEmpty) return;
    context.push(
      AppRoutes.gallery,
      extra: GalleryRouteData(
        imageUrls: images.map((e) => e.imageUrl).toList(),
        initialIndex: initialIndex,
      ),
    );
  }

  void _openBoulderDetail(BoulderModel boulder) {
    context.push(AppRoutes.boulderDetail, extra: boulder);
  }

  Widget _buildHeader(
    RouteModel route,
    String location,
    BoulderModel? connectedBoulder,
    String? fallbackBoulderName,
  ) {
    final isLiked = route.liked;
    final likeCount = route.likeCount;
    final displayBoulderName =
        (connectedBoulder?.name ?? fallbackBoulderName ?? '').trim();
    final shouldShowBoulderName = displayBoulderName.isNotEmpty;
    final shouldShowLocation = !shouldShowBoulderName && location.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _levelColor(route.routeLevel).withValues(alpha: 0.2),
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
                child: Text(
                  route.name,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: shouldShowBoulderName || shouldShowLocation
                    ? GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: shouldShowBoulderName && connectedBoulder != null
                            ? () => _openBoulderDetail(connectedBoulder)
                            : null,
                        child: Row(
                          children: [
                            Icon(
                              shouldShowBoulderName
                                  ? Icons.landscape_rounded
                                  : CupertinoIcons.location_solid,
                              size: 18,
                              color: const Color(0xFF7C7C7C),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              shouldShowBoulderName
                                  ? displayBoulderName
                                  : location,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                color:
                                    shouldShowBoulderName &&
                                        connectedBoulder != null
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight:
                                    shouldShowBoulderName &&
                                        connectedBoulder != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MiniMetric(
                    icon: isLiked
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    value: likeCount,
                    color: isLiked ? Colors.red : Colors.white70,
                    onTap: _isTogglingLike ? null : _toggleLike,
                  ),
                  const SizedBox(width: 12),
                  _MiniMetric(
                    icon: CupertinoIcons.person_2_fill,
                    value: route.climberCount,
                  ),
                ],
              ),
            ],
          ),
          if (route.pioneerName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'by ${route.pioneerName}',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white54,
                fontSize: 13,
              ),
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

enum _ExistingProjectAction { viewList, edit, cancel }

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
        Icon(icon, size: 16, color: color ?? Colors.white70),
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

  const _RouteImageViewer({required this.images, required this.initialIndex});

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
                onPressed: () => context.pop(),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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

Color _levelColor(String level) {
  final normalized = level.trim().toUpperCase();
  int? numericLevel;
  final digitMatch = RegExp(r'(\d+)').firstMatch(normalized);
  if (digitMatch != null) {
    numericLevel = int.tryParse(digitMatch.group(1)!);
  } else if (normalized.contains('VB')) {
    numericLevel = 0;
  }

  if (numericLevel != null) {
    if (numericLevel <= 1) return const Color(0xFF4CAF50);
    if (numericLevel <= 3) return const Color(0xFFF2C94C);
    if (numericLevel <= 5) return const Color(0xFFF2994A);
    return const Color(0xFFE57373);
  }

  if (normalized.contains('초')) return const Color(0xFF4CAF50);
  if (normalized.contains('중')) return const Color(0xFFF2C94C);
  if (normalized.contains('상')) return const Color(0xFFE57373);
  return const Color(0xFF7E57C2);
}
