import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/boulder/application/boulder_store.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_boulder_like_use_case.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoulderDetailDesc extends ConsumerWidget {
  const BoulderDetailDesc({super.key, required this.boulder});

  final BoulderModel boulder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(boulderEntityProvider(boulder.id)) ?? boulder;
    final locationText = entity.city.isEmpty
        ? entity.province
        : '${entity.province} ${entity.city}';

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 5, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entity.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF9498A1),
                          size: 20,
                        ),
                        Text(
                          locationText,
                          style: const TextStyle(
                            color: Color(0xFF7C7C7C),
                            fontSize: 14,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _DetailLikeButton(boulder: entity),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
            child: Text(
              entity.description.trim().isNotEmpty
                  ? entity.description.trim()
                  : 'Maecenas sed diam eget risus varius blandit sit amet non magna. Integer posuere erat a ante... (바위 설명)',
              style: const TextStyle(
                fontFamily: 'SFPRO',
                color: Color(0xFF7C7C7C),
                fontSize: 14,
                letterSpacing: 0.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLikeButton extends ConsumerStatefulWidget {
  const _DetailLikeButton({required this.boulder});

  final BoulderModel boulder;

  @override
  ConsumerState<_DetailLikeButton> createState() => _DetailLikeButtonState();
}

class _DetailLikeButtonState extends ConsumerState<_DetailLikeButton> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final entity =
        ref.watch(boulderEntityProvider(widget.boulder.id)) ?? widget.boulder;
    return Row(
      children: [
        GestureDetector(
          onTap: _isProcessing ? null : _handleToggle,
          child: Icon(
            entity.liked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: entity.liked ? Colors.red : const Color(0xFF9498A1),
            size: 24,
          ),
        ),
        const SizedBox(width: 4),
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
    final store = ref.read(boulderStoreProvider.notifier);
    final current =
        ref.read(boulderEntityProvider(widget.boulder.id)) ?? widget.boulder;
    store.applyLikeResult(
      LikeToggleResult(
        boulderId: current.id,
        liked: !current.liked,
        likeCount: current.likeCount + (!current.liked ? 1 : -1),
      ),
    );
    try {
      final toggle = di<ToggleBoulderLikeUseCase>();
      final result = await toggle(widget.boulder.id);
      store.applyLikeResult(result);
    } catch (error) {
      store.applyLikeResult(
        LikeToggleResult(
          boulderId: current.id,
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
