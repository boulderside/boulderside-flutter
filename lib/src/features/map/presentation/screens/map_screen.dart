import 'package:boulderside_flutter/src/features/boulder/presentation/screens/boulder_detail.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_service.dart';
import 'package:boulderside_flutter/src/features/home/presentation/screens/route_detail_page.dart';
import 'package:boulderside_flutter/src/features/map/presentation/viewmodels/map_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapViewModel>(
      create: (context) => MapViewModel(
        context.read<BoulderService>(),
        context.read<RouteService>(),
      )..load(),
      child: const _MapScreenContent(),
    );
  }
}

class _MapScreenContent extends StatefulWidget {
  const _MapScreenContent();

  @override
  State<_MapScreenContent> createState() => _MapScreenContentState();
}

class _MapScreenContentState extends State<_MapScreenContent> {
  NaverMapController? _mapController;
  MapPin? _selectedPin;
  bool _isMapReady = false;
  bool _handlersBound = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handlersBound) {
      final viewModel = context.read<MapViewModel>();
      viewModel
        ..setPinTapHandler(_handlePinTap)
        ..setClusterTapHandler(_handleClusterTap);
      _handlersBound = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, viewModel, child) {
        _scheduleMarkerSync(viewModel);
        final List<MapPin> pins = viewModel.pins;

        return Scaffold(
          backgroundColor: const Color(0xFF181A20),
          appBar: AppBar(
            backgroundColor: const Color(0xFF181A20),
            automaticallyImplyLeading: false,
            title: const Text(
              '지도',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: NaverMap(
                  options: const NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: NLatLng(37.5665, 126.9780),
                      zoom: 7,
                    ),
                    locationButtonEnable: true,
                    nightModeEnable: true,
                    logoClickEnable: false,
                  ),
                  onMapReady: (controller) =>
                      _onMapReady(viewModel, controller),
                  onMapTapped: (point, latLng) {
                    if (_selectedPin != null) {
                      setState(() {
                        _selectedPin = null;
                      });
                    }
                  },
                  onCameraIdle: _handleCameraIdle,
                ),
              ),
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: _LayerToggleBar(
                  activeLayer: viewModel.activeLayer,
                  onLayerSelected: (layer) {
                    setState(() {
                      _selectedPin = null;
                    });
                    viewModel.changeLayer(layer);
                  },
                ),
              ),
              if (viewModel.isLoading)
                const Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF3278)),
                  ),
                ),
              if (viewModel.errorMessage != null)
                Positioned(
                  top: 90,
                  left: 16,
                  right: 16,
                  child: _ErrorBanner(message: viewModel.errorMessage!),
                ),
              if (!viewModel.isLoading && pins.isEmpty)
                const Positioned(
                  top: 140,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      '표시할 위치 데이터가 없습니다.',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              if (_selectedPin != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _SelectionDetailSheet(
                    pin: _selectedPin!,
                    onClose: () => setState(() => _selectedPin = null),
                    onViewDetail: () => _openDetail(_selectedPin!),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _scheduleMarkerSync(MapViewModel viewModel) {
    if (!_isMapReady) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncMarkers(viewModel);
    });
  }

  Future<void> _syncMarkers(MapViewModel viewModel) async {
    final NaverMapController? controller = _mapController;
    if (controller == null) {
      return;
    }

    final Set<NMarker> markers = viewModel.currentMarkers.toSet();

    await controller.clearOverlays(type: NOverlayType.marker);
    if (markers.isNotEmpty) {
      await controller.addOverlayAll(markers.cast<NAddableOverlay>());
    }
  }

  void _handlePinTap(MapPin pin) {
    setState(() {
      _selectedPin = pin;
    });
    _focusOnPin(pin);
  }

  void _handleClusterTap(NLatLng target, double targetZoom) {
    setState(() {
      _selectedPin = null;
    });
    _animateCamera(target, targetZoom);
  }

  Future<void> _focusOnPin(MapPin pin) async {
    final controller = _mapController;
    if (controller == null) return;
    final currentPosition = await controller.getCameraPosition();
    await _animateCamera(
      NLatLng(pin.latitude, pin.longitude),
      currentPosition.zoom,
    );
  }

  Future<void> _animateCamera(NLatLng target, double zoom) async {
    final controller = _mapController;
    if (controller == null) return;
    final update = NCameraUpdate.scrollAndZoomTo(
      target: target,
      zoom: zoom,
    )
      ..setReason(NCameraUpdateReason.developer)
      ..setAnimation(
        animation: NCameraAnimation.easing,
        duration: const Duration(milliseconds: 400),
      );
    await controller.updateCamera(update);
  }

  void _handleCameraIdle() {
    if (!mounted) return;
    final viewModel = context.read<MapViewModel>();
    _refreshMarkers(viewModel);
  }

  void _onMapReady(MapViewModel viewModel, NaverMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
    _refreshMarkers(viewModel);
  }

  Future<void> _refreshMarkers(MapViewModel viewModel) async {
    final controller = _mapController;
    if (controller == null) return;
    final cameraPosition = await controller.getCameraPosition();
    final bounds = await controller.getContentBounds(withPadding: true);
    await viewModel.rebuildMarkers(
      zoom: cameraPosition.zoom,
      bounds: bounds,
    );
    _scheduleMarkerSync(viewModel);
  }

  void _openDetail(MapPin pin) {
    if (pin.layerType == MapLayerType.boulder && pin.boulder != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BoulderDetail(boulder: pin.boulder!)),
      );
    } else if (pin.layerType == MapLayerType.route && pin.route != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RouteDetailPage(route: pin.route!)),
      );
    }
  }
}

class _SelectionDetailSheet extends StatelessWidget {
  const _SelectionDetailSheet({
    required this.pin,
    required this.onClose,
    required this.onViewDetail,
  });

  final MapPin pin;
  final VoidCallback onClose;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    if (pin.layerType == MapLayerType.boulder) {
      return _BoulderDetailSheet(
        pin: pin,
        onClose: onClose,
        onViewDetail: onViewDetail,
      );
    } else {
      return _RouteDetailSheet(
        pin: pin,
        onClose: onClose,
        onViewDetail: onViewDetail,
      );
    }
  }
}

class _BoulderDetailSheet extends StatelessWidget {
  const _BoulderDetailSheet({
    required this.pin,
    required this.onClose,
    required this.onViewDetail,
  });

  final MapPin pin;
  final VoidCallback onClose;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final boulder = pin.boulder!;
    final String? description = boulder.description.trim().isEmpty
        ? null
        : boulder.description.trim();

    return _SheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(imageUrl: pin.thumbnailUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      boulder.name,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (pin.locationLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          pin.locationLabel!,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.heart_fill,
                          size: 16,
                          color: Color(0xFFFF3278),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${boulder.likeCount}',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  CupertinoIcons.xmark,
                  color: Colors.white54,
                ),
                onPressed: onClose,
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white70,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          _SheetButton(
            label: '상세정보 보기',
            onTap: onViewDetail,
          ),
        ],
      ),
    );
  }
}

class _RouteDetailSheet extends StatelessWidget {
  const _RouteDetailSheet({
    required this.pin,
    required this.onClose,
    required this.onViewDetail,
  });

  final MapPin pin;
  final VoidCallback onClose;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final route = pin.route!;
    return _SheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _RouteBadge(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.name,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (pin.locationLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          pin.locationLabel!,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C313A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            route.routeLevel,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          CupertinoIcons.heart_fill,
                          size: 16,
                          color: Color(0xFFFF3278),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${route.likeCount}',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  CupertinoIcons.xmark,
                  color: Colors.white54,
                ),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SheetButton(
            label: '루트 상세 보기',
            onTap: onViewDetail,
          ),
        ],
      ),
    );
  }
}

class _SheetContainer extends StatelessWidget {
  const _SheetContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: const Color(0xFF1E2129),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF3278),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontFamily: 'Pretendard'),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _placeholder();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!,
        width: 86,
        height: 86,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: const Color(0xFF2C313A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(CupertinoIcons.photo, color: Colors.white54, size: 28),
    );
  }
}

class _RouteBadge extends StatelessWidget {
  const _RouteBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: const Color(0xFF3555F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          CupertinoIcons.flag,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

class _LayerToggleBar extends StatelessWidget {
  const _LayerToggleBar({
    required this.activeLayer,
    required this.onLayerSelected,
  });

  final MapLayerType activeLayer;
  final ValueChanged<MapLayerType> onLayerSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xAA1E2129),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LayerToggleChip(
              label: '바위',
              selected: activeLayer == MapLayerType.boulder,
              onTap: () => onLayerSelected(MapLayerType.boulder),
            ),
            const SizedBox(width: 6),
            _LayerToggleChip(
              label: '루트',
              selected: activeLayer == MapLayerType.route,
              onTap: () => onLayerSelected(MapLayerType.route),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayerToggleChip extends StatelessWidget {
  const _LayerToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF3278) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
