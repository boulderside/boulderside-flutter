import 'package:boulderside_flutter/home/models/rec_boulder_model.dart';
import 'package:boulderside_flutter/home/services/rec_boulder_service.dart';
import 'package:boulderside_flutter/utils/widget_extensions.dart';

import 'dart:ui';
import 'package:flutter/material.dart';

class RecBoulderList extends StatefulWidget {
  const RecBoulderList({super.key});

  @override
  State<RecBoulderList> createState() => _RecBoulderListState();
}

class _RecBoulderListState extends State<RecBoulderList> {
  final ScrollController _scrollController = ScrollController();
  final List<RecBoulderModel> _boulders = [];

  int? _cursorId;
  bool _isLoading = false;
  final int _pageSize = 6;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
  }

  @override
  void initState() {
    super.initState();
    _loadMore();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_isLoading) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final newItems = await RecBoulderService().fetchRecommendedBoulders(
      cursorId: _cursorId,
      size: _pageSize,
    );

    setState(() {
      _boulders.addAll(newItems);
      if (newItems.isNotEmpty) {
        _cursorId = newItems.last.id;
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              children: _boulders
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
                            boulder.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          boulder.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList()
                  .divide(SizedBox(width: 15)),
            ),
          ),
        ),
      ),
    );
  }
}
