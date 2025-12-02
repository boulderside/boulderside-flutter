import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MapPin {
  const MapPin({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.boulder,
    this.locationLabel,
    this.thumbnailUrl,
  });

  final String id;
  final double latitude;
  final double longitude;
  final BoulderModel boulder;
  final String? locationLabel;
  final String? thumbnailUrl;

  NLatLng get latLng => NLatLng(latitude, longitude);
}

class MapViewModel extends ChangeNotifier {
  MapViewModel(this._boulderService);

  final BoulderService _boulderService;

  bool _isLoading = false;
  String? _errorMessage;
  final Map<int, BoulderModel> _boulderCache = <int, BoulderModel>{};
  List<MapPin> _boulderPins = <MapPin>[];
  List<NMarker> _currentMarkers = <NMarker>[];
  bool _isFetchingAll = false;
  bool _hasLoadedAll = false;
  void Function(MapPin pin)? _pinTapHandler;
  void Function(NLatLng target, double targetZoom)? _clusterTapHandler;
  final _ClusterIconFactory _clusterIconFactory = _ClusterIconFactory();
  final _MarkerIconFactory _markerIconFactory = _MarkerIconFactory();

  static const double _minZoom = 5;
  static const double _maxZoom = 18;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UnmodifiableListView<MapPin> get pins =>
      UnmodifiableListView<MapPin>(_boulderPins);
  UnmodifiableListView<NMarker> get currentMarkers =>
      UnmodifiableListView<NMarker>(_currentMarkers);

  Future<void> load() async {
    _boulderCache.clear();
    _boulderPins = <MapPin>[];
    _currentMarkers = <NMarker>[];
    _hasLoadedAll = false;
    _errorMessage = null;
    notifyListeners();
  }

  void setPinTapHandler(void Function(MapPin pin)? handler) {
    _pinTapHandler = handler;
  }

  void setClusterTapHandler(
    void Function(NLatLng target, double targetZoom)? handler,
  ) {
    _clusterTapHandler = handler;
  }

  Future<void> rebuildMarkers({
    required double zoom,
    required NLatLngBounds bounds,
  }) async {
    try {
      await _ensureAllDataLoaded();
    } catch (e) {
      debugPrint('Map data fetch failed: $e');
      _errorMessage = '지도 데이터를 불러오지 못했습니다.';
    }

    final List<MapPin> basePins = _boulderPins;
    if (basePins.isEmpty) {
      if (_currentMarkers.isNotEmpty) {
        _currentMarkers = <NMarker>[];
        notifyListeners();
      }
      return;
    }

    final List<MapPin> visiblePins = basePins
        .where((pin) => _isWithinBounds(pin, bounds))
        .toList();
    final bool shouldCluster = zoom <= 11;

    final List<NMarker> nextMarkers = visiblePins.isEmpty
        ? <NMarker>[]
        : shouldCluster
        ? await _buildClusterMarkers(visiblePins, zoom)
        : await _buildIndividualMarkers(visiblePins);

    _currentMarkers = nextMarkers;
    notifyListeners();
  }

  void _buildPins() {
    _boulderPins = _boulderCache.values
        .where(_hasValidCoordinates)
        .map(
          (BoulderModel boulder) => MapPin(
            id: 'boulder_${boulder.id}',
            latitude: boulder.latitude,
            longitude: boulder.longitude,
            boulder: boulder,
            locationLabel: _buildLocationLabel(boulder.province, boulder.city),
            thumbnailUrl: _firstImageUrl(boulder),
          ),
        )
        .toList();
  }

  bool _hasValidCoordinates(BoulderModel boulder) {
    final double lat = boulder.latitude;
    final double lng = boulder.longitude;
    if (lat == 0 && lng == 0) {
      return false;
    }
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  String? _buildLocationLabel(String province, String city) {
    final List<String> parts = <String>[];
    if (province.trim().isNotEmpty) {
      parts.add(province.trim());
    }
    if (city.trim().isNotEmpty) {
      parts.add(city.trim());
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' ');
  }

  String? _firstImageUrl(BoulderModel boulder) {
    if (boulder.imageInfoList.isEmpty) {
      return null;
    }
    return boulder.imageInfoList.first.imageUrl;
  }

  bool _isWithinBounds(MapPin pin, NLatLngBounds bounds) {
    return bounds.containsPoint(pin.latLng);
  }

  Future<void> _ensureAllDataLoaded() async {
    if (_hasLoadedAll || _isFetchingAll) {
      return;
    }

    _isFetchingAll = true;
    _setLoading(true);
    try {
      final List<BoulderModel> boulders = await _boulderService
          .fetchAllBoulders();

      for (final boulder in boulders) {
        _boulderCache[boulder.id] = boulder;
      }
      _hasLoadedAll = true;
      _buildPins();
    } finally {
      _isFetchingAll = false;
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  Future<List<NMarker>> _buildIndividualMarkers(List<MapPin> pins) async {
    final List<NMarker> markers = <NMarker>[];
    for (final pin in pins) {
      markers.add(await _createMarkerFromPin(pin));
    }
    return markers;
  }

  Future<NMarker> _createMarkerFromPin(MapPin pin) async {
    final NOverlayImage icon = await _markerIconFactory.icon();
    final NMarker marker = NMarker(
      id: pin.id,
      position: pin.latLng,
      icon: icon,
      caption: NOverlayCaption(
        text: pin.boulder.name,
        color: Colors.white,
        textSize: 13,
        haloColor: const Color(0xFF12141A),
      ),
      subCaption: pin.locationLabel == null
          ? null
          : NOverlayCaption(
              text: pin.locationLabel!,
              color: Colors.white70,
              textSize: 11,
            ),
      isHideCollidedCaptions: true,
    );

    marker.setOnTapListener((overlay) {
      _pinTapHandler?.call(pin);
    });

    return marker;
  }

  Future<List<NMarker>> _buildClusterMarkers(
    List<MapPin> pins,
    double zoom,
  ) async {
    final double cellSize = _cellSizeForZoom(zoom);
    final Map<String, _ClusterBucket> buckets = <String, _ClusterBucket>{};

    for (final MapPin pin in pins) {
      final int gx = (pin.longitude / cellSize).floor();
      final int gy = (pin.latitude / cellSize).floor();
      final String key = '$gx:$gy';
      final bucket = buckets.putIfAbsent(key, () => _ClusterBucket(key));
      bucket.add(pin);
    }

    final List<NMarker> markers = <NMarker>[];
    for (final bucket in buckets.values) {
      markers.add(await _createClusterMarker(bucket, zoom));
    }
    return markers;
  }

  Future<NMarker> _createClusterMarker(
    _ClusterBucket bucket,
    double zoom,
  ) async {
    final NLatLng centroid = bucket.centroid;
    final NOverlayImage icon = await _clusterIconFactory.iconForCount(
      bucket.count,
    );
    final NMarker marker = NMarker(
      id: 'cluster_${bucket.key}',
      position: centroid,
      icon: icon,
      isHideCollidedCaptions: true,
    );

    marker.setOnTapListener((overlay) {
      final targetZoom = math.min(_maxZoom, math.max(_minZoom, zoom + 2));
      _clusterTapHandler?.call(centroid, targetZoom);
    });

    return marker;
  }

  double _cellSizeForZoom(double zoom) {
    if (zoom >= 14) return 0.01; // ~1km
    if (zoom >= 12) return 0.03;
    if (zoom >= 10) return 0.08;
    if (zoom >= 8) return 0.2;
    return 0.4;
  }
}

class _ClusterBucket {
  _ClusterBucket(this.key);

  final String key;
  final List<MapPin> pins = <MapPin>[];
  double _sumLat = 0;
  double _sumLng = 0;

  void add(MapPin pin) {
    pins.add(pin);
    _sumLat += pin.latitude;
    _sumLng += pin.longitude;
  }

  int get count => pins.length;

  NLatLng get centroid => NLatLng(_sumLat / count, _sumLng / count);
}

class _ClusterIconFactory {
  static const double _diameter = 96;

  final Map<int, NOverlayImage> _cache = <int, NOverlayImage>{};

  Future<NOverlayImage> iconForCount(int count) async {
    final int bucket = _bucketize(count);
    final NOverlayImage? cached = _cache[bucket];
    if (cached != null) {
      return cached;
    }
    final Uint8List bytes = await _drawBadge(bucket);
    final NOverlayImage image = await NOverlayImage.fromByteArray(bytes);
    _cache[bucket] = image;
    return image;
  }

  static int _bucketize(int count) {
    if (count < 10) return count;
    if (count < 50) return (count ~/ 5) * 5;
    if (count < 100) return (count ~/ 10) * 10;
    return (count ~/ 50) * 50;
  }

  Future<Uint8List> _drawBadge(int count) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    const ui.Size size = ui.Size(_diameter, _diameter);
    final ui.Offset center = ui.Offset(size.width / 2, size.height / 2);

    final ui.Paint fillPaint = ui.Paint()..color = const Color(0xCC1A1D24);
    canvas.drawCircle(center, size.width / 2, fillPaint);

    final ui.Paint borderPaint = ui.Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, size.width / 2 - 2, borderPaint);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          fontFamily: 'Pretendard',
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);

    final ui.Offset textOffset =
        center - ui.Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, textOffset);

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return data!.buffer.asUint8List();
  }
}

class _MarkerIconFactory {
  static const double _diameter = 96;

  NOverlayImage? _cached;

  Future<NOverlayImage> icon() async {
    final NOverlayImage? cached = _cached;
    if (cached != null) {
      return cached;
    }
    final Uint8List bytes = await _drawBadge();
    final NOverlayImage image = await NOverlayImage.fromByteArray(bytes);
    _cached = image;
    return image;
  }

  Future<Uint8List> _drawBadge() async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    const ui.Size size = ui.Size(_diameter, _diameter);
    final ui.Offset center = ui.Offset(size.width / 2, size.height / 2);

    final ui.Paint fillPaint = ui.Paint()..color = const Color(0xFFFF4F8B);
    canvas.drawCircle(center, size.width / 2, fillPaint);

    final ui.Paint sheenPaint = ui.Paint()
      ..shader = ui.Gradient.linear(
        const ui.Offset(0, 0),
        ui.Offset(size.width, size.height),
        <Color>[Colors.white.withValues(alpha: 0.18), Colors.transparent],
      );
    canvas.drawCircle(center, size.width / 2, sheenPaint);
    _drawBoulderGlyph(canvas, center);

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return data!.buffer.asUint8List();
  }

  void _drawBoulderGlyph(ui.Canvas canvas, ui.Offset center) {
    final ui.Path rock = ui.Path()
      ..moveTo(center.dx - 18, center.dy + 16)
      ..lineTo(center.dx - 8, center.dy - 12)
      ..lineTo(center.dx + 4, center.dy - 6)
      ..lineTo(center.dx + 12, center.dy - 18)
      ..lineTo(center.dx + 20, center.dy + 12)
      ..close();
    canvas.drawPath(
      rock,
      ui.Paint()
        ..color = Colors.white
        ..style = ui.PaintingStyle.fill,
    );

    final ui.Paint ridge = ui.Paint()
      ..color = const Color(0xFFF4C7D7)
      ..strokeWidth = 3
      ..style = ui.PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round;
    canvas.drawLine(
      ui.Offset(center.dx - 4, center.dy - 2),
      ui.Offset(center.dx + 10, center.dy + 8),
      ridge,
    );
  }
}
