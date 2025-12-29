import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/cache/route_index_cache.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/create_instagram_use_case.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RouteInstagramCreatePage extends StatefulWidget {
  const RouteInstagramCreatePage({super.key, this.initialRoute});

  final RouteModel? initialRoute;

  @override
  State<RouteInstagramCreatePage> createState() =>
      _RouteInstagramCreatePageState();
}

class _RouteInstagramCreatePageState extends State<RouteInstagramCreatePage> {
  late final TextEditingController _urlController;
  late final PageController _pageController;
  late Future<List<RouteModel>> _routesFuture;
  late List<RouteModel> _selectedRoutes;
  String _searchQuery = '';
  bool _isSubmitting = false;
  int _currentStep = 0;
  String? _selectedBoulder;
  String? _selectedLevel;
  String? _instagramEmbedUrl;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _pageController = PageController();
    _routesFuture = di<RouteIndexCache>().load();
    _selectedRoutes = widget.initialRoute == null ? [] : [widget.initialRoute!];
    _urlController.addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    final url = _urlController.text.trim();
    final isValidUrl = _isValidInstagramUrl(url);

    if (isValidUrl) {
      if (_instagramEmbedUrl != url) {
        setState(() {
          _instagramEmbedUrl = url;
          _webViewController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0xFF181A20))
            ..loadRequest(
              Uri.dataFromString(
                _generateHtmlContent(url),
                mimeType: 'text/html',
              ),
            );
        });
      }
    } else {
      if (_instagramEmbedUrl != null) {
        setState(() {
          _instagramEmbedUrl = null;
          _webViewController = null;
        });
      }
    }
  }

  bool _isValidInstagramUrl(String url) {
    if (url.isEmpty) return false;

    final regExp = RegExp(
      r'instagram\.com/(?:p|reel)/[A-Za-z0-9_-]+',
      caseSensitive: false,
    );

    return regExp.hasMatch(url);
  }

  String _generateHtmlContent(String url) {
    return '''
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <style>
    body {
      margin: 0;
      padding: 8px;
      background: #181A20;
      display: flex;
      justify-content: center;
      align-items: flex-start;
    }
    .post {
      width: 100%;
      max-width: 500px;
    }
    .instagram-media {
      margin: 0 !important;
      width: 100% !important;
      min-width: 0 !important;
    }
  </style>
</head>
<body>
  <div class="post">
    <blockquote
      class="instagram-media"
      data-instgrm-permalink="$url"
      data-instgrm-version="14">
    </blockquote>
  </div>
  <script async defer src="https://platform.instagram.com/en_US/embeds.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      if (window.instgrm) {
        window.instgrm.Embeds.process();
      }
    });
  </script>
</body>
</html>
    ''';
  }

  void _nextStep() {
    if (_currentStep == 0) {
      final url = _urlController.text.trim();
      if (url.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('인스타그램 링크를 입력해주세요.')));
        return;
      }
      setState(() => _currentStep = 1);
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep == 1) {
      setState(() => _currentStep = 0);
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () {
            if (_currentStep == 1) {
              _previousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          '내 베타 등록하기',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [_buildStep1(), _buildStep2()],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : (_currentStep == 0 ? _nextStep : _submit),
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
                  : Text(
                      _currentStep == 0 ? '다음' : '등록 완료',
                      style: const TextStyle(
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

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '인스타그램 링크 (1/2)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '완등한 루트의 인스타그램 게시글 링크를 붙여넣어주세요.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 24),
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
          if (_webViewController != null && _instagramEmbedUrl != null) ...[
            const SizedBox(height: 24),
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFF262A34),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: WebViewWidget(controller: _webViewController!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: _selectedRoutes.isNotEmpty ? 140 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '루트 선택 (2/2)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '영상에서 완등한 루트를 검색하여 태그해주세요.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  onChanged: (value) => setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  }),
                  decoration: InputDecoration(
                    hintText: '루트 이름 또는 암장 이름으로 검색',
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
                const SizedBox(height: 16),
                _buildFilters(),
                const SizedBox(height: 16),
                FutureBuilder<List<RouteModel>>(
                  future: _routesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF3278),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
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
                        ),
                      );
                    }

                    final routes = snapshot.data ?? <RouteModel>[];
                    final filteredRoutes = _filterRoutes(routes);

                    if (filteredRoutes.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            '검색 결과가 없습니다.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                      );
                    }

                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(
                          bottom: _selectedRoutes.isNotEmpty ? 120 : 0,
                        ),
                        itemCount: filteredRoutes.length,
                        separatorBuilder: (context, index) =>
                            const Divider(color: Color(0xFF262A34), height: 1),
                        itemBuilder: (context, index) {
                          final route = filteredRoutes[index];
                          final isSelected = _selectedRoutes.any(
                            (r) => r.id == route.id,
                          );
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
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
                              '${route.routeLevel} · ${route.boulderName ?? ""}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.add_circle_outline,
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
        ),
        if (_selectedRoutes.isNotEmpty) _buildSelectedRoutesChips(),
      ],
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip(
          label: _selectedBoulder ?? '바위 선택',
          isSelected: _selectedBoulder != null,
          onTap: () => _showBoulderFilter(),
        ),
        _buildFilterChip(
          label: _selectedLevel ?? '난이도 선택',
          isSelected: _selectedLevel != null,
          onTap: () => _showLevelFilter(),
        ),
        if (_selectedBoulder != null || _selectedLevel != null)
          _buildFilterChip(
            label: '필터 초기화',
            isSelected: false,
            onTap: () {
              setState(() {
                _selectedBoulder = null;
                _selectedLevel = null;
              });
            },
            icon: Icons.clear,
          ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF3278).withValues(alpha: 0.2)
              : const Color(0xFF262A34),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF3278) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF3278) : Colors.white70,
                fontSize: 13,
                fontFamily: 'Pretendard',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedRoutesChips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                '선택된 루트',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3278),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedRoutes.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _selectedRoutes.asMap().entries.map((entry) {
                final index = entry.key;
                final route = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _selectedRoutes.length - 1 ? 8 : 0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3278).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFF3278),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          route.name,
                          style: const TextStyle(
                            color: Color(0xFFFF3278),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRoutes.removeWhere(
                                (r) => r.id == route.id,
                              );
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFFFF3278),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<RouteModel> _filterRoutes(List<RouteModel> routes) {
    var filtered = routes;

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((route) {
        final name = route.name.toLowerCase();
        final boulder = route.boulderName?.toLowerCase().trim();
        return name.contains(_searchQuery) ||
            (boulder?.contains(_searchQuery) ?? false);
      }).toList();
    }

    // Boulder filter
    if (_selectedBoulder != null) {
      filtered = filtered.where((route) {
        return route.boulderName == _selectedBoulder;
      }).toList();
    }

    // Level filter
    if (_selectedLevel != null) {
      filtered = filtered.where((route) {
        return route.routeLevel == _selectedLevel;
      }).toList();
    }

    return filtered;
  }

  void _showBoulderFilter() async {
    final routes = await _routesFuture;
    final boulders =
        routes
            .map((r) => r.boulderName)
            .where((name) => name != null && name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF262A34),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  '바위 선택',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: boulders.length,
                  itemBuilder: (context, index) {
                    final boulder = boulders[index];
                    return ListTile(
                      title: Text(
                        boulder!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedBoulder = boulder;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLevelFilter() async {
    final routes = await _routesFuture;
    final levels =
        routes
            .map((r) => r.routeLevel)
            .where((level) => level.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF262A34),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  '난이도 선택',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    return ListTile(
                      title: Text(
                        level,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedLevel = level;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
