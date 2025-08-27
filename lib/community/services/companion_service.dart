import '../models/companion_post.dart';

class CompanionService {
  // 실제 API 통신으로 바뀔 예정
  Future<List<CompanionPost>> fetchCompanions({
    int? cursorId,
    int size = 10,
  }) async {
    // 실제 API 요청 시 이렇게 보냄
    // final response = await dio.get('/api/companions', queryParameters: {
    //   'cursor': cursorId,
    //   'size': size,
    // });

    // 더미 데이터로 cursorId를 int로 가정
    final start = (cursorId ?? 0);

    final List<CompanionPost> result = List.generate(size, (i) {
      final id = start + i + 1;
      final locations = ['관악산', '북한산', '설악산', '지리산', '한라산', '도봉산', '남양주', '인천'];
      final titles = [
        '주말 등반 동행을 구합니다',
        '평일 저녁 바위타기 함께해요',
        '초보자 환영! 같이 클라이밍',
        '러닝과 바위 타기 조합',
        '경험자와 함께 도전해요',
        '아침 일찍 바위타기',
        '새로운 루트 탐험',
        '사진 촬영하며 등반',
      ];
      final authors = ['climber$id', 'rockstar$id', 'bouldering$id', 'adventure$id'];
      
      return CompanionPost(
        title: '${titles[i % titles.length]} - ${locations[i % locations.length]}',
        meetingPlace: locations[i % locations.length],
        meetingDateLabel: _generateRandomDate(id),
        authorNickname: authors[i % authors.length],
        commentCount: (id * 2) % 15,
        viewCount: 50 + (id * 7) % 200,
        createdAt: DateTime.now().subtract(Duration(hours: id % 48, minutes: id % 60)),
        content: '${titles[i % titles.length]}에 참여하실 분을 찾습니다. ${locations[i % locations.length]}에서 만나서 함께 즐겁게 등반해요!',
      );
    });

    // API 호출 시뮬레이션을 위한 지연
    await Future.delayed(Duration(milliseconds: 500));

    return result;
  }

  String _generateRandomDate(int seed) {
    final now = DateTime.now();
    final daysAhead = (seed % 14) + 1; // 1-14 days ahead
    final futureDate = now.add(Duration(days: daysAhead));
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[futureDate.weekday - 1];
    
    return '${futureDate.year}.${futureDate.month.toString().padLeft(2, '0')}.${futureDate.day.toString().padLeft(2, '0')} ($weekday)';
  }
}