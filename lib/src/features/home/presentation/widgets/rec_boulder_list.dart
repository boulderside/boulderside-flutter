import 'package:boulderside_flutter/src/features/home/data/services/rec_boulder_service.dart';
import 'package:boulderside_flutter/src/features/home/presentation/viewmodels/rec_boulder_list_view_model.dart';
import 'package:boulderside_flutter/src/shared/mixins/infinite_scroll_mixin.dart';
import 'package:boulderside_flutter/src/shared/utils/widget_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecBoulderList extends StatefulWidget {
  const RecBoulderList({super.key});

  @override
  State<RecBoulderList> createState() => _RecBoulderListState();
}

class _RecBoulderListState extends State<RecBoulderList>
    with InfiniteScrollMixin<RecBoulderList> {
  RecBoulderListViewModel? _viewModel;

  @override
  bool get canLoadMore =>
      _viewModel != null && !_viewModel!.isLoading && _viewModel!.hasNext;

  @override
  Future<void> onNearBottom() async {
    await _viewModel?.loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecBoulderListViewModel(
        context.read<RecBoulderService>(),
      )..loadInitial(),
      child: Consumer<RecBoulderListViewModel>(
        builder: (context, vm, _) {
          // Store the viewModel reference for scroll listener
          _viewModel = vm;
          
          // 최초 데이터 로드 (목록 비어있고 로딩 중)
          if (vm.isLoading && vm.boulders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF3278)),
            );
          }

          if (vm.errorMessage != null && vm.boulders.isEmpty) {
            return SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  vm.errorMessage!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
            child: Container(
              height: 80,
              decoration: BoxDecoration(),
              child: Align(
                alignment: AlignmentDirectional(-1, 0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...vm.boulders
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
                                  child: _BoulderAvatar(imageUrl: boulder
                                          .imageInfoList.isNotEmpty
                                      ? boulder.imageInfoList.first.imageUrl
                                      : null),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 50, // 이미지와 같은 너비만큼 텍스트의 너비를 지정
                                  child: Text(
                                    boulder.name,
                                    maxLines: 1, // 한 줄로 제한
                                    overflow:
                                        TextOverflow.ellipsis, // 넘치면 ... 처리
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
                          .divide(SizedBox(width: 15)),
                      
                      // 로딩 인디케이터
                      if (vm.errorMessage != null && vm.boulders.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        )
                      else if (vm.isLoading)
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: const Center(
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
        },
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
