import 'package:boulderside_flutter/home/models/route_model.dart';

class RouteService {
  // 실제 API 통신으로 바뀔 예정
  Future<List<RouteModel>> fetchBoulders({int? cursorId, int size = 10}) async {
    // 실제 API 요청 시 이렇게 보냄
    // final response = await dio.get('/api/boulders', queryParameters: {
    //   'cursor': cursorId,
    //   'size': size,
    // });

    // 더미 데이터로 cursorId를 int로 가정
    final start = (cursorId ?? 0);

    final List<RouteModel> result = List.generate(size, (i) {
      final id = start + i + 1;
      final locations = ['관악산', '북한산', '설악산', '지리산', '한라산'];

      return RouteModel(
        id: id,
        name: '${locations[i % locations.length]} 루트 $id',
        routeLevel: "v12",
        likes: 1000 - id * 3,
        isLiked: id % 2 == 0,
        climbers: 1000,
      );
    });

    // API 호출 시뮬레이션을 위한 지연
    await Future.delayed(Duration(milliseconds: 500));

    return result;
  }
}
