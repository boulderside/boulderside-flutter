class ImageInfoModel {
  // BOULDER, POINT, ROUTE, USER 중 1개
  final String targetType;

  // 이미지의 url 정보
  final String imageUrl;

  // target이 되는 것의 id에 대한 이미지 순서 정보
  final int orderIndex;

  const ImageInfoModel({
    required this.targetType,
    required this.imageUrl,
    required this.orderIndex,
  });
}
