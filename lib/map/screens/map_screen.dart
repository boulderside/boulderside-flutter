import 'package:boulderside_flutter/boulder/screens/boulder_detail.dart';
import 'package:boulderside_flutter/home/services/boulder_service.dart';
import 'package:boulderside_flutter/map/viewmodels/map_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapViewModel>(
      create: (_) => MapViewModel(BoulderService())..load(),
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
                  onMapReady: (controller) {
                    _mapController = controller;
                    setState(() {
                      _isMapReady = true;
                    });
                    _syncMarkers(viewModel);
                  },
                  onMapTapped: (point, latLng) {
                    if (_selectedPin != null) {
                      setState(() {
                        _selectedPin = null;
                      });
                    }
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
                  child: _BoulderDetailSheet(
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

    final List<MapPin> pins = viewModel.pins;
    final Set<NMarker> markers = pins.map(_buildMarker).toSet();

    await controller.clearOverlays(type: NOverlayType.marker);
    if (markers.isNotEmpty) {
      await controller.addOverlayAll(markers.cast<NAddableOverlay>());
    }
  }

  NMarker _buildMarker(MapPin pin) {
    final NMarker marker = NMarker(
      id: pin.id,
      position: NLatLng(pin.latitude, pin.longitude),
      caption: NOverlayCaption(
        text: pin.boulder.name,
        color: const Color(0xFF12141A),
        textSize: 14,
        haloColor: Colors.white,
        // maxLines: 1,
      ),
      subCaption: pin.locationLabel == null
          ? null
          : NOverlayCaption(
              text: pin.locationLabel!,
              color: const Color(0xFF2E323C),
              textSize: 12,
            ),
      iconTintColor: const Color(0xFFFF3278),
      isHideCollidedCaptions: true,
      isHideCollidedMarkers: false,
    );

    marker.setOnTapListener((overlay) {
      setState(() {
        _selectedPin = pin;
      });
      _focusOnPin(pin);
    });

    return marker;
  }

  Future<void> _focusOnPin(MapPin pin) async {
    final controller = _mapController;
    if (controller == null) return;
    final update =
        NCameraUpdate.scrollAndZoomTo(
            target: NLatLng(pin.latitude, pin.longitude),
            zoom: 11,
          )
          ..setReason(NCameraUpdateReason.developer)
          ..setAnimation(
            animation: NCameraAnimation.easing,
            duration: const Duration(milliseconds: 400),
          );
    await controller.updateCamera(update);
  }

  void _openDetail(MapPin pin) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BoulderDetail(boulder: pin.boulder)),
    );
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

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: const Color(0xFF1E2129),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BoulderThumbnail(imageUrl: pin.thumbnailUrl),
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
                SizedBox(
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
                    onPressed: onViewDetail,
                    child: const Text(
                      '상세정보 보기',
                      style: TextStyle(fontFamily: 'Pretendard'),
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

class _BoulderThumbnail extends StatelessWidget {
  const _BoulderThumbnail({this.imageUrl});

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
