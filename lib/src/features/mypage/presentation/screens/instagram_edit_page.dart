import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/cache/route_index_cache.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram.dart';
import 'package:boulderside_flutter/src/features/mypage/application/my_instagrams_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class InstagramEditPageArgs {
  const InstagramEditPageArgs({required this.instagram});

  final Instagram instagram;
}

class InstagramEditPage extends ConsumerStatefulWidget {
  const InstagramEditPage({super.key, required this.args});

  final InstagramEditPageArgs args;

  @override
  ConsumerState<InstagramEditPage> createState() => _InstagramEditPageState();
}

class _InstagramEditPageState extends ConsumerState<InstagramEditPage> {
  late final TextEditingController _urlController;
  late Future<List<RouteModel>> _routesFuture;
  List<RouteModel> _selectedRoutes = [];
  bool _didInitSelection = false;
  String _searchQuery = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.args.instagram.url);
    _routesFuture = di<RouteIndexCache>().load();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '인스타그램 수정',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<List<RouteModel>>(
        future: _routesFuture,
        builder: (context, snapshot) {
          final routes = snapshot.data ?? const <RouteModel>[];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          if (snapshot.hasData && !_didInitSelection) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final routeMap = {for (final route in routes) route.id: route};
              final selected = widget.args.instagram.routeIds
                  .map((id) => routeMap[id])
                  .whereType<RouteModel>()
                  .toList();
              setState(() {
                _selectedRoutes = selected;
                _didInitSelection = true;
              });
            });
          }

          return _buildBody(context, routes, snapshot.hasError, isLoading);
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3278),
                disabledBackgroundColor: const Color(
                  0xFFFF3278,
                ).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      '수정 완료',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<RouteModel> routes,
    bool hasRouteError,
    bool isRouteLoading,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'URL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '인스타그램 게시글 링크를 입력해주세요.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _urlController,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Pretendard',
            ),
            textAlignVertical: TextAlignVertical.center,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              hintText: 'https://www.instagram.com/p/...',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: const Color(0xFF262A34),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.instagram,
                    color: Colors.white54,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                '연결된 루트',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
              const Spacer(),
              Text(
                '선택 ${_selectedRoutes.length}개',
                style: const TextStyle(
                  color: Colors.white54,
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() {
              _searchQuery = value.trim().toLowerCase();
            }),
            decoration: InputDecoration(
              hintText: '루트 이름으로 검색',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: const Color(0xFF262A34),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Pretendard',
            ),
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 12),
          if (hasRouteError)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '루트 목록을 불러오지 못했습니다.',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _routesFuture = di<RouteIndexCache>().refresh();
                            });
                          },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          _buildRouteList(routes, isRouteLoading),
        ],
      ),
    );
  }

  Widget _buildRouteList(List<RouteModel> routes, bool isRouteLoading) {
    final filteredRoutes = _searchQuery.isEmpty
        ? routes
        : routes
              .where((route) => route.name.toLowerCase().contains(_searchQuery))
              .toList();

    if (isRouteLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(color: Color(0xFFFF3278)),
        ),
      );
    }

    if (routes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '루트 목록이 없습니다.',
          style: TextStyle(color: Colors.white54, fontFamily: 'Pretendard'),
        ),
      );
    }

    if (filteredRoutes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '검색 결과가 없습니다.',
          style: TextStyle(color: Colors.white54, fontFamily: 'Pretendard'),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 320),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: filteredRoutes.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Color(0xFF262A34), height: 1),
        itemBuilder: (context, index) {
          final route = filteredRoutes[index];
          final isSelected = _selectedRoutes.any((item) => item.id == route.id);
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            title: Text(
              route.name,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF3278) : Colors.white,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${route.routeLevel} · ${route.province} ${route.city}',
              style: const TextStyle(
                color: Colors.white54,
                fontFamily: 'Pretendard',
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                isSelected ? Icons.remove_circle_outline : Icons.add_circle,
                color: isSelected ? const Color(0xFFFF3278) : Colors.white54,
              ),
              onPressed: _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        final exists = _selectedRoutes.any(
                          (item) => item.id == route.id,
                        );
                        if (exists) {
                          _selectedRoutes.removeWhere(
                            (item) => item.id == route.id,
                          );
                        } else {
                          _selectedRoutes.add(route);
                        }
                      });
                    },
            ),
            onTap: () {
              context.push(AppRoutes.routeDetail, extra: route);
            },
          );
        },
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('인스타그램 링크를 입력해주세요.')));
      return;
    }

    if (_selectedRoutes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('연결할 루트를 선택해주세요.')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final success = await ref
          .read(myInstagramsStoreProvider.notifier)
          .updateInstagram(
            instagramId: widget.args.instagram.id,
            url: url,
            routeIds: _selectedRoutes.map((route) => route.id).toList(),
          );
      if (!mounted) return;
      if (success) {
        navigator.pop();
        messenger.showSnackBar(const SnackBar(content: Text('수정이 완료되었습니다.')));
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('수정에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
