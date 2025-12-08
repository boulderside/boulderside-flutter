import 'package:boulderside_flutter/src/features/boulder/application/boulder_store.dart';
import 'package:boulderside_flutter/src/shared/mixins/infinite_scroll_mixin.dart';
import 'package:boulderside_flutter/src/shared/utils/widget_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecBoulderList extends ConsumerStatefulWidget {
  const RecBoulderList({super.key});

  @override
  ConsumerState<RecBoulderList> createState() => _RecBoulderListState();
}

class _RecBoulderListState extends ConsumerState<RecBoulderList>
    with InfiniteScrollMixin<RecBoulderList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(boulderStoreProvider.notifier).loadInitialRecommended();
    });
  }

  @override
  bool get canLoadMore {
    final feed = ref.read(recommendedBoulderFeedProvider);
    return !feed.isLoadingMore && feed.hasNext;
  }

  @override
  Future<void> onNearBottom() async {
    await ref.read(boulderStoreProvider.notifier).loadMoreRecommended();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(recommendedBoulderFeedProvider);

    if (feed.isInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF3278)),
      );
    }

    if (feed.errorMessage != null && feed.items.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(
            feed.errorMessage!,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
      child: SizedBox(
        height: 80,
        child: Align(
          alignment: const AlignmentDirectional(-1, 0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                ...feed.items
                    .map(
                      (boulder) => Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: _BoulderAvatar(
                              imageUrl: boulder.imageInfoList.isNotEmpty
                                  ? boulder.imageInfoList.first.imageUrl
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 50, // 이미지와 같은 너비만큼 텍스트의 너비를 지정
                            child: Text(
                              boulder.name,
                              maxLines: 1, // 한 줄로 제한
                              overflow: TextOverflow.ellipsis, // 넘치면 ... 처리
                              softWrap: false,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList()
                    .divide(const SizedBox(width: 15)),
                if (feed.errorMessage != null && feed.items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      feed.errorMessage!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  )
                else if (feed.isLoadingMore)
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF3278),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BoulderAvatar extends StatelessWidget {
  const _BoulderAvatar({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF2F3440),
        ),
        child: const Icon(
          CupertinoIcons.photo,
          color: Color(0xFF7C7C7C),
          size: 24,
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFF2F3440),
          child: const Icon(
            CupertinoIcons.photo,
            color: Color(0xFF7C7C7C),
            size: 24,
          ),
        );
      },
    );
  }
}
