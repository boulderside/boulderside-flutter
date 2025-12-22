import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/cache/route_index_cache.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/create_instagram_use_case.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class RouteInstagramCreatePage extends StatefulWidget {
  const RouteInstagramCreatePage({super.key, this.initialRoute});

  final RouteModel? initialRoute;

  @override
  State<RouteInstagramCreatePage> createState() =>
      _RouteInstagramCreatePageState();
}

class _RouteInstagramCreatePageState extends State<RouteInstagramCreatePage> {
  late final TextEditingController _urlController;
  late Future<List<RouteModel>> _routesFuture;
  late List<RouteModel> _selectedRoutes;
  String _searchQuery = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _routesFuture = di<RouteIndexCache>().load();
    _selectedRoutes = widget.initialRoute == null ? [] : [widget.initialRoute!];
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
          '내 풀이 등록하기',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
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
            const SizedBox(height: 24),
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
            FutureBuilder<List<RouteModel>>(
              future: _routesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF3278),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Column(
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
                                  _routesFuture = di<RouteIndexCache>()
                                      .refresh();
                                });
                              },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  );
                }

                final routes = snapshot.data ?? <RouteModel>[];
                final filteredRoutes = _searchQuery.isEmpty
                    ? routes
                    : routes.where((route) {
                        final name = route.name.toLowerCase();
                        final boulder = route.boulderName?.toLowerCase().trim();
                        return name.contains(_searchQuery) ||
                            (boulder?.contains(_searchQuery) ?? false);
                      }).toList();

                if (filteredRoutes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        '루트가 없습니다.',
                        style: TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                  );
                }

                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.separated(
                    itemCount: filteredRoutes.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Color(0xFF262A34), height: 1),
                    itemBuilder: (context, index) {
                      final route = filteredRoutes[index];
                      final isSelected = _selectedRoutes.any(
                        (r) => r.id == route.id,
                      );
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        title: Text(
                          route.name,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFFF3278)
                                : Colors.white,
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
                            isSelected
                                ? Icons.remove_circle_outline
                                : Icons.add_circle,
                            color: isSelected
                                ? const Color(0xFFFF3278)
                                : Colors.white54,
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    final exists = _selectedRoutes.any(
                                      (r) => r.id == route.id,
                                    );
                                    if (exists) {
                                      _selectedRoutes.removeWhere(
                                        (r) => r.id == route.id,
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
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
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
                      '등록 완료',
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

  Future<void> _submit() async {
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
      ).showSnackBar(const SnackBar(content: Text('루트를 1개 이상 선택해주세요.')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await di<CreateInstagramUseCase>().execute(
        url: url,
        routeIds: _selectedRoutes.map((r) => r.id).toList(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('등록 실패: ${e.toString()}')));
    }
  }
}
