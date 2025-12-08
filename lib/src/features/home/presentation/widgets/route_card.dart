import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_route_like_use_case.dart';
import 'package:boulderside_flutter/src/features/route/application/route_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteCard extends ConsumerWidget {
  const RouteCard({
    super.key,
    required this.route,
    this.showChevron = false,
    this.onTap,
  });

  final RouteModel route;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(routeEntityProvider(route.id)) ?? route;
    final content = Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        showChevron ? 10 : 20,
        0,
        showChevron ? 10 : 20,
        showChevron ? 0 : 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              color: const Color(0xFF262A34),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      10,
                      showChevron ? 0 : 15,
                      10,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                showChevron ? 0 : 10,
                                0,
                                0,
                                0,
                              ),
                              child: Text(
                                entity.name,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      10,
                      5,
                      10,
                      15,
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            showChevron ? 0 : 10,
                            0,
                            0,
                            0,
                          ),
                          child: Text(
                            entity.routeLevel,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _RouteLikeButton(route: entity),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 10),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.person_2,
                                size: 20,
                                color: Color(0xFF9498A1),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${entity.climberCount}',
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showChevron)
            IconButton(
              icon: const Icon(
                CupertinoIcons.chevron_forward,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: onTap,
            ),
        ],
      ),
    );

    if (showChevron) {
      return content;
    }
    return GestureDetector(onTap: onTap, child: content);
  }
}

class _RouteLikeButton extends ConsumerStatefulWidget {
  const _RouteLikeButton({required this.route});

  final RouteModel route;

  @override
  ConsumerState<_RouteLikeButton> createState() => _RouteLikeButtonState();
}

class _RouteLikeButtonState extends ConsumerState<_RouteLikeButton> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final entity =
        ref.watch(routeEntityProvider(widget.route.id)) ?? widget.route;
    return Row(
      children: [
        GestureDetector(
          onTap: _isProcessing ? null : _handleToggle,
          child: Icon(
            entity.isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: entity.isLiked ? Colors.red : const Color(0xFF9498A1),
            size: 18,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${entity.likes}',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Future<void> _handleToggle() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });
    final notifier = ref.read(routeStoreProvider.notifier);
    final current =
        ref.read(routeEntityProvider(widget.route.id)) ?? widget.route;
    notifier.applyLikeResult(
      LikeToggleResult(
        routeId: current.id,
        liked: !current.isLiked,
        likeCount: current.likes + (!current.isLiked ? 1 : -1),
      ),
    );
    try {
      final toggle = di<ToggleRouteLikeUseCase>();
      final result = await toggle(widget.route.id);
      notifier.applyLikeResult(result);
    } catch (error) {
      notifier.applyLikeResult(
        LikeToggleResult(
          routeId: current.id,
          liked: current.isLiked,
          likeCount: current.likes,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('좋아요를 변경하지 못했습니다: $error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
