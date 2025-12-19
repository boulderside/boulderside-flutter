import 'dart:math' as math;
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/map/application/map_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  NaverMapController? _mapController;
  MapPin? _selectedPin;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    final store = ref.read(mapStoreProvider.notifier);
    store
      ..setPinTapHandler(_handlePinTap)
      ..setClusterTapHandler(_handleClusterTap);
    store.load();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapStoreProvider);

    _scheduleMarkerSync(mapState.currentMarkers);

    final mapWidget = NaverMap(
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
          _onMapReady(ref.read(mapStoreProvider.notifier), controller),
      onMapTapped: (point, latLng) {
        if (_selectedPin != null) {
          setState(() => _selectedPin = null);
        }
      },
      onCameraIdle: () =>
          _handleCameraIdle(ref.read(mapStoreProvider.notifier)),
    );

    return _MapViewLayout(
      mapState: mapState,
      mapWidget: mapWidget,
      selectedPin: _selectedPin,
      onCloseSelection: () => setState(() => _selectedPin = null),
      onViewDetail: _openDetail,
      onFocusBoulder: _handlePinTap,
      pins: mapState.pins,
    );
  }

  void _scheduleMarkerSync(List<NMarker> markers) {
    if (!_isMapReady) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncMarkers(markers);
    });
  }

  Future<void> _syncMarkers(List<NMarker> markers) async {
    final NaverMapController? controller = _mapController;
    if (controller == null) {
      return;
    }

    await controller.clearOverlays(type: NOverlayType.marker);
    final overlayMarkers = markers.toSet();
    if (overlayMarkers.isNotEmpty) {
      await controller.addOverlayAll(overlayMarkers.cast<NAddableOverlay>());
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
    final targetZoom = math.max(currentPosition.zoom, 16.0);
    await _animateCamera(NLatLng(pin.latitude, pin.longitude), targetZoom);
  }

  Future<void> _animateCamera(NLatLng target, double zoom) async {
    final controller = _mapController;
    if (controller == null) return;
    final update = NCameraUpdate.scrollAndZoomTo(target: target, zoom: zoom)
      ..setReason(NCameraUpdateReason.developer)
      ..setAnimation(
        animation: NCameraAnimation.easing,
        duration: const Duration(milliseconds: 400),
      );
    await controller.updateCamera(update);
  }

  void _handleCameraIdle(MapStore store) {
    if (!mounted) return;
    _refreshMarkers(store);
  }

  void _onMapReady(MapStore store, NaverMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
    _refreshMarkers(store);
  }

  Future<void> _refreshMarkers(MapStore store) async {
    final controller = _mapController;
    if (controller == null) return;
    final cameraPosition = await controller.getCameraPosition();
    final bounds = await controller.getContentBounds(withPadding: true);
    await store.rebuildMarkers(zoom: cameraPosition.zoom, bounds: bounds);
    _scheduleMarkerSync(ref.read(mapStoreProvider).currentMarkers);
  }

  void _openDetail(MapPin pin) {
    context.push(AppRoutes.boulderDetail, extra: pin.boulder);
  }
}

class _MapViewLayout extends StatelessWidget {
  const _MapViewLayout({
    required this.mapState,
    required this.mapWidget,
    required this.selectedPin,
    required this.onCloseSelection,
    required this.onViewDetail,
    required this.onFocusBoulder,
    required this.pins,
  });

  final MapStoreState mapState;
  final Widget mapWidget;
  final MapPin? selectedPin;
  final VoidCallback onCloseSelection;
  final void Function(MapPin pin) onViewDetail;
  final void Function(MapPin pin) onFocusBoulder;
  final List<MapPin> pins;

  @override
  Widget build(BuildContext context) {
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
          Positioned.fill(child: mapWidget),
          if (mapState.isLoading)
            const Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF3278)),
              ),
            ),
          if (mapState.errorMessage != null)
            Positioned(
              top: 90,
              left: 16,
              right: 16,
              child: _ErrorBanner(message: mapState.errorMessage!),
            ),
          if (!mapState.isLoading && pins.isEmpty)
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
          if (selectedPin == null &&
              !mapState.isLoading &&
              mapState.visiblePins.isNotEmpty)
            _VisibleBouldersSheet(
              visiblePins: mapState.visiblePins,
              onViewDetail: onViewDetail,
              onFocusBoulder: onFocusBoulder,
            ),
          if (selectedPin != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BoulderDetailSheet(
                pin: selectedPin!,
                onClose: onCloseSelection,
                onViewDetail: () => onViewDetail(selectedPin!),
              ),
            ),
        ],
      ),
    );
  }
}

class _VisibleBouldersSheet extends StatefulWidget {
  const _VisibleBouldersSheet({
    required this.visiblePins,
    required this.onViewDetail,
    required this.onFocusBoulder,
  });

  final List<MapPin> visiblePins;
  final void Function(MapPin pin) onViewDetail;
  final void Function(MapPin pin) onFocusBoulder;

  @override
  State<_VisibleBouldersSheet> createState() => _VisibleBouldersSheetState();
}

class _VisibleBouldersSheetState extends State<_VisibleBouldersSheet> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _expandSheet() {
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onHeaderDragUpdate(DragUpdateDetails details) {
    if (!_sheetController.isAttached) return;

    // DraggableScrollableSheet occupies the full height of its parent (the Stack).
    final double sheetAreaHeight = context.size?.height ??
        MediaQuery.of(context).size.height;
    
    // Dragging down (positive delta) decreases the sheet size (0.0 - 1.0).
    // We subtract because the size origin is bottom-up (0.0 is empty, 1.0 is full).
    final double sizeDelta = details.primaryDelta! / sheetAreaHeight;
    final double newSize = _sheetController.size - sizeDelta;

    _sheetController.jumpTo(newSize);
  }

  void _onHeaderDragEnd(DragEndDetails details) {
    if (!_sheetController.isAttached) return;

    final double velocity = details.primaryVelocity ?? 0;

    // Swipe down fast -> Close to min (0.12)
    if (velocity > 600) {
      _sheetController.animateTo(
        0.12,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    // Swipe up fast -> Expand to max (0.85)
    if (velocity < -600) {
      _sheetController.animateTo(
        0.85,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    // Snap to nearest
    final double currentSize = _sheetController.size;
    final List<double> snapSizes = [0.12, 0.5, 0.85];
    final double nearest = snapSizes.reduce(
      (a, b) => (a - currentSize).abs() < (b - currentSize).abs() ? a : b,
    );

    _sheetController.animateTo(
      nearest,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.12,
      minChildSize: 0.12,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.12, 0.5, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E2129),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _BottomSheetHeaderDelegate(
                  onTap: _expandSheet,
                  count: widget.visiblePins.length,
                  onVerticalDragUpdate: _onHeaderDragUpdate,
                  onVerticalDragEnd: _onHeaderDragEnd,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Item - Divider - Item pattern
                    if (index.isOdd) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(color: Colors.white10, height: 1),
                      );
                    }
                    final itemIndex = index ~/ 2;
                    final pin = widget.visiblePins[itemIndex];
                    return _buildListItem(pin);
                  },
                  childCount: math.max(0, widget.visiblePins.length * 2 - 1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListItem(MapPin pin) {
    return GestureDetector(
      onTap: () {
        widget.onFocusBoulder(pin);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            _Thumbnail(imageUrl: pin.thumbnailUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pin.boulder.name,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.heart_fill,
                        size: 14,
                        color: Color(0xFFFF3278),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pin.boulder.likeCount}',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  _BottomSheetHeaderDelegate({
    required this.onTap,
    required this.count,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
  });

  final VoidCallback onTap;
  final int count;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;

  static const double _height = 68.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return GestureDetector(
      onTap: onTap,
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _height,
        decoration: const BoxDecoration(
          color: Color(0xFF1E2129),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Improved Handle Bar
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '현재 지도에 $count개의 바위가 있어요',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: Colors.white10, height: 1),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(covariant _BottomSheetHeaderDelegate oldDelegate) {
    return oldDelegate.count != count;
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
    final boulder = pin.boulder;
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
                icon: const Icon(CupertinoIcons.xmark, color: Colors.white54),
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
          _SheetButton(label: '상세정보 보기', onTap: onViewDetail),
        ],
      ),
    );
  }
}

class _SheetContainer extends StatelessWidget {
  const _SheetContainer({required this.child});

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
          child: Padding(padding: const EdgeInsets.all(16), child: child),
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
        child: Text(label, style: const TextStyle(fontFamily: 'Pretendard')),
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
