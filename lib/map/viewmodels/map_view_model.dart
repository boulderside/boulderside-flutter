import 'dart:collection';

import 'package:boulderside_flutter/home/models/boulder_model.dart';
import 'package:boulderside_flutter/home/services/boulder_service.dart';
import 'package:flutter/foundation.dart';

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
}

class MapViewModel extends ChangeNotifier {
  MapViewModel(this._boulderService);

  final BoulderService _boulderService;

  bool _isLoading = false;
  String? _errorMessage;
  List<BoulderModel> _boulders = <BoulderModel>[];
  List<MapPin> _pins = <MapPin>[];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UnmodifiableListView<MapPin> get pins => UnmodifiableListView<MapPin>(_pins);

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _boulders = await _boulderService.fetchAllBoulders();
      _buildPins();
    } catch (e) {
      debugPrint('Map data load error: $e');
      _errorMessage = '지도 데이터를 불러오지 못했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _buildPins() {
    _pins = _boulders
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
}
