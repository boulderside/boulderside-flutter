import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/boulder/application/boulder_store.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_boulder_like_use_case.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoulderCard extends ConsumerWidget {
  const BoulderCard({super.key, required this.boulder});

  final BoulderModel boulder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(boulderEntityProvider(boulder.id)) ?? boulder;
    final String? imageUrl = entity.imageInfoList.isNotEmpty
        ? entity.imageInfoList.first.imageUrl
        : null;
    final bool hasValidImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    final locationText = entity.city.isEmpty
        ? entity.province
        : '${entity.province} ${entity.city}';

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: const Color(0xFF262A34),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: hasValidImage
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFF2F3440),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: const Color(0xFF7C7C7C),
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 20, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                    child: Text(
                      entity.name,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _LikeButton(boulder: entity),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.location_solid,
                            color: Color(0xFF7C7C7C),
                            size: 24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            locationText,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: const Color(0xFF2F3440),
      child: const Center(
        child: Icon(CupertinoIcons.photo, color: Color(0xFF7C7C7C), size: 40),
      ),
    );
  }
}

class _LikeButton extends ConsumerStatefulWidget {
  const _LikeButton({required this.boulder});

  final BoulderModel boulder;

  @override
  ConsumerState<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<_LikeButton> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final entity =
        ref.watch(boulderEntityProvider(widget.boulder.id)) ?? widget.boulder;
    return Row(
      children: [
        IconButton(
          icon: Icon(
            entity.liked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: entity.liked ? Colors.red : const Color(0xFF9498A1),
            size: 24,
          ),
          onPressed: _isProcessing ? null : _handleToggle,
        ),
        Text(
          '${entity.likeCount}',
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
    final notifier = ref.read(boulderStoreProvider.notifier);
    final previous =
        ref.read(boulderEntityProvider(widget.boulder.id)) ?? widget.boulder;
    final optimisticResult = LikeToggleResult(
      boulderId: previous.id,
      liked: !previous.liked,
      likeCount: previous.likeCount + (!previous.liked ? 1 : -1),
    );
    notifier.applyLikeResult(optimisticResult);
    try {
      final toggle = di<ToggleBoulderLikeUseCase>();
      final result = await toggle(widget.boulder.id);
      notifier.applyLikeResult(result);
    } catch (error) {
      notifier.applyLikeResult(
        LikeToggleResult(
          boulderId: previous.id,
          liked: previous.liked,
          likeCount: previous.likeCount,
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
