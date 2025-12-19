import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/boulder/application/boulder_store.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_boulder_like_use_case.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoulderLikeButton extends ConsumerStatefulWidget {
  const BoulderLikeButton({super.key, required this.boulder});

  final BoulderModel boulder;

  @override
  ConsumerState<BoulderLikeButton> createState() => _BoulderLikeButtonState();
}

class _BoulderLikeButtonState extends ConsumerState<BoulderLikeButton> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final entity =
        ref.watch(boulderEntityProvider(widget.boulder.id)) ?? widget.boulder;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _isProcessing ? null : _handleToggle,
            child: Icon(
              entity.liked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              color: entity.liked ? Colors.red : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '${entity.likeCount}',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
