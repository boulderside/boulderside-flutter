import '../models/rec_boulder_model.dart';

class RecBoulderService {
  // 실제 API 통신으로 바뀔 예정
  Future<List<RecBoulderModel>> fetchRecommendedBoulders({
    int? cursorId,
    int size = 6,
  }) async {
    // 실제 API 요청 시 이렇게 보냄
    // final response = await dio.get('/api/rec/boulders', queryParameters: {
    //   'boulderId': 123,
    //   'cursor': cursorId,
    //   'size': size,
    // });

    // 더미 데이터로 cursorId를 int로 가정
    // 다음 ID부터 size개 생성

    final start = (cursorId ?? 0) + 1;

    final List<RecBoulderModel> result = List.generate(size, (i) {
      final id = start;
      return RecBoulderModel(
        id: id,
        name: '관악산 $id',
        imageUrl: 'https://picsum.photos/seed/649/600',
      );
    });

    return result;
  }
}
