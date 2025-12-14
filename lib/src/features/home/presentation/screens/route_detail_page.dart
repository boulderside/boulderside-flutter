import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/community/application/comment_store.dart';
import 'package:boulderside_flutter/src/features/community/data/models/comment_models.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/comment_card.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/comment_input.dart';
import 'package:boulderside_flutter/src/domain/entities/image_info_model.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_route_like_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_store.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/project_form_page.dart';
import 'package:boulderside_flutter/src/features/route/application/route_store.dart';
import 'package:boulderside_flutter/src/shared/navigation/gallery_route_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class RouteDetailArguments {
  final RouteModel route;
  final int? scrollToCommentId;

  const RouteDetailArguments({required this.route, this.scrollToCommentId});
}

class RouteDetailPage extends ConsumerStatefulWidget {
  final RouteModel route;
  final int? scrollToCommentId;

  const RouteDetailPage({
    super.key,
    required this.route,
    this.scrollToCommentId,
  });

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
  bool _hasProject = false;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  bool _hasScrolledToComment = false;

  @override
  void initState() {
    super.initState();
    _toggleRouteLike = di<ToggleRouteLikeUseCase>();
    _pageController = PageController();
    _itemPositionsListener.itemPositions.addListener(_onScroll);

    final cachedDetail = ref.read(routeDetailProvider(widget.route.id)).detail;
    if (cachedDetail == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchDetail();
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(projectStoreProvider.notifier)
          .fetchProjectByRoute(widget.route.id);
      ref
          .read(commentStoreProvider.notifier)
          .loadInitial('routes', widget.route.id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final feed = ref.read(commentFeedProvider(('routes', widget.route.id)));
    if (feed.isLoading || !feed.hasNext) return;

    final lastVisibleIndex = positions
        .where((position) => position.itemTrailingEdge > 0)
        .reduce((max, position) => position.index > max.index ? position : max)
        .index;

    final totalItems = 2 + feed.comments.length + (feed.isLoadingMore ? 1 : 0);

    if (lastVisibleIndex >= totalItems - 2) {
      ref
          .read(commentStoreProvider.notifier)
          .loadMore('routes', widget.route.id);
    }
  }

  void _checkAndScrollToComment(List<CommentResponseModel> comments) {
    if (_hasScrolledToComment || widget.scrollToCommentId == null) return;

    final index = comments.indexWhere(
      (c) => c.commentId == widget.scrollToCommentId,
    );
    if (index != -1) {
      _hasScrolledToComment = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_itemScrollController.isAttached) {
          _itemScrollController.scrollTo(
            index: index + 2,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  Future<void> _fetchDetail({bool force = false}) async {
    try {
      await ref
          .read(routeStoreProvider.notifier)
          .fetchDetail(widget.route.id, force: force);
      if (force) {
        await ref
            .read(commentStoreProvider.notifier)
            .loadInitial('routes', widget.route.id);
      }
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

  void _showEditCommentDialog(CommentResponseModel comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '댓글 수정',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: CommentInput(
            initialText: comment.content,
            hintText: '댓글을 수정하세요...',
            submitText: '수정',
            isLoading: ref
                .watch(commentFeedProvider(('routes', widget.route.id)))
                .isSubmitting,
            onSubmit: (content) {
              ref
                  .read(commentStoreProvider.notifier)
                  .editComment(
                    'routes',
                    widget.route.id,
                    comment.commentId,
                    content,
                  );
              context.pop();
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              '취소',
              style: TextStyle(fontFamily: 'Pretendard', color: Colors.white54),
            ),
          ),
        ],
      ),
    );
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
    final projectState = ref.watch(projectStoreProvider);
    _syncProjectFlag(projectState);

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
          centerTitle: false,
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              tooltip: '프로젝트 등록',
              icon: Icon(
                _hasProject ? CupertinoIcons.flag_fill : CupertinoIcons.flag,
                color: Colors.white,
              ),
              color: const Color(0xFF262A34),
              onSelected: (value) async {
                switch (value) {
                  case 'myProjects':
                    context.push(AppRoutes.myRoutes);
                    break;
                  case 'detail':
                    final existing = _findExistingProject(widget.route.id);
                    if (existing != null && context.mounted) {
                      context.push(AppRoutes.projectDetail, extra: existing);
                    }
                    break;
                  case 'add':
                    await _openOrCreateProjectForm(context);
                    break;
                }
              },
              itemBuilder: (context) {
                final existing = _findExistingProject(widget.route.id);
                if (existing == null) {
                  return const [
                    PopupMenuItem(
                      value: 'add',
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.add, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '프로젝트 등록',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'myProjects',
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.list_bullet, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '내 프로젝트 목록',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                }
                return const [
                  PopupMenuItem(
                    value: 'myProjects',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.list_bullet, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '내 프로젝트 목록',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.doc_text, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '프로젝트 상세',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
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

  Future<void> _openOrCreateProjectForm(BuildContext context) async {
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

  void _syncProjectFlag(ProjectState state) {
    final exists = state.projects.any(
      (project) => project.routeId == widget.route.id,
    );
    if (exists != _hasProject) {
      setState(() {
        _hasProject = exists;
      });
    }
  }

  Future<void> _showProjectForm(
    BuildContext context, {
    ProjectModel? completion,
    RouteModel? initialRoute,
  }) async {
    if (!mounted) return;
    final bool? saved = await context.push<bool>(
      AppRoutes.projectForm,
      extra: ProjectFormArguments(
        completion: completion,
        initialRoute: initialRoute,
      ),
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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF23262F),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          dialogContext.pop(_ExistingProjectAction.viewList),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3278),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('프로젝트 목록 보러가기'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () =>
                          dialogContext.pop(_ExistingProjectAction.edit),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('기존 프로젝트 수정하기'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          dialogContext.pop(_ExistingProjectAction.cancel),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        textStyle: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('닫기'),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

    final commentFeed = ref.watch(
      commentFeedProvider(('routes', widget.route.id)),
    );
    final commentNotifier = ref.read(commentStoreProvider.notifier);

    _checkAndScrollToComment(commentFeed.comments);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _fetchDetail(force: true),
            color: const Color(0xFFFF3278),
            backgroundColor: _cardColor,
            child: ScrollablePositionedList.builder(
              itemScrollController: _itemScrollController,
              itemPositionsListener: _itemPositionsListener,
              itemCount:
                  2 +
                  commentFeed.comments.length +
                  (commentFeed.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildImageCarousel(images),
                      _buildHeader(
                        route,
                        location,
                        connectedBoulder,
                        connectedBoulderName.isEmpty
                            ? null
                            : connectedBoulderName,
                      ),
                      _buildDescription(description),
                      const SizedBox(height: 20),
                    ],
                  );
                } else if (index == 1) {
                  return Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      20,
                      16,
                      20,
                      8,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF181A20),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF262A34), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '댓글',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${commentFeed.comments.length}',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            color: Color(0xFFFF3278),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  final commentIndex = index - 2;
                  if (commentIndex < commentFeed.comments.length) {
                    final comment = commentFeed.comments[commentIndex];
                    return CommentCard(
                      comment: comment,
                      onEdit: () => _showEditCommentDialog(comment),
                      onDelete: () => commentNotifier.deleteComment(
                        'routes',
                        widget.route.id,
                        comment.commentId,
                      ),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF3278),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ),
        CommentInput(
          hintText: '댓글을 입력하세요...',
          submitText: '등록',
          isLoading: commentFeed.isSubmitting,
          onSubmit: (content) =>
              commentNotifier.addComment('routes', widget.route.id, content),
        ),
      ],
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
