import 'package:boulderside_flutter/src/features/home/data/services/rec_boulder_service.dart';
import 'package:boulderside_flutter/src/features/home/presentation/viewmodels/rec_boulder_list_view_model.dart';
import 'package:boulderside_flutter/src/shared/utils/widget_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecBoulderList extends StatefulWidget {
  const RecBoulderList({super.key});

  @override
  State<RecBoulderList> createState() => _RecBoulderListState();
}

class _RecBoulderListState extends State<RecBoulderList> {
  final ScrollController _scrollController = ScrollController();
  RecBoulderListViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_viewModel == null) return;
    
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold &&
        !_viewModel!.isLoading &&
        _viewModel!.hasNext) {
      _viewModel!.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          RecBoulderListViewModel(RecBoulderService())..loadInitial(),
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
                    controller: _scrollController,
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
                                  child: Image.network(
                                    boulder.imageInfoList.first.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
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
                      if (vm.isLoading)
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
