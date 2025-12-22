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
    this.outerPadding,
    this.showEngagement = true,
    this.footer,
  });

  final RouteModel route;
  final bool showChevron;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? outerPadding;
  final bool showEngagement;
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(routeEntityProvider(route.id)) ?? route;
    final isFullWidth = showChevron;
    final outerPaddingValue =
        outerPadding ??
        (isFullWidth
            ? const EdgeInsets.only(bottom: 12)
            : const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 14));
    final innerPadding = EdgeInsetsDirectional.fromSTEB(
      isFullWidth ? 0 : 16,
      isFullWidth ? 12 : 16,
      isFullWidth ? 0 : 16,
      isFullWidth ? 12 : 16,
    );
    final backgroundColor = isFullWidth
        ? Colors.transparent
        : const Color(0xFF262A34);
    final borderRadius = BorderRadius.circular(isFullWidth ? 0 : 8);

    final cardContent = Padding(
      padding: outerPaddingValue,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: innerPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _levelColor(
                        entity.routeLevel,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      entity.routeLevel,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entity.name,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (entity.completed) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle,
                      size: 24,
                      color: Color(0xFF4CAF50),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.landscape_rounded,
                          size: 18,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entity.boulderName ?? '',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showEngagement) ...[
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _RouteLikeButton(route: entity),
                      ],
                    ),
                  ],
                ],
              ),
              if (footer != null) ...[const SizedBox(height: 12), footer!],
            ],
          ),
        ),
      ),
    );

    if (onTap == null) {
      return cardContent;
    }
    return GestureDetector(onTap: onTap, child: cardContent);
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
            size: 22,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${entity.likeCount}',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 17,
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
        liked: !current.liked,
        likeCount: current.likeCount + (!current.liked ? 1 : -1),
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
          liked: current.liked,
          likeCount: current.likeCount,
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
