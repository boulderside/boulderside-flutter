class ImageInfoModel {
  // BOULDER, POINT, ROUTE, USER 중 1개
  final String targetType;

  // 이미지의 url 정보
  final String imageUrl;

  // target이 되는 것의 id에 대한 이미지 순서 정보
  final int? orderIndex;

  ImageInfoModel({
    required this.targetType,
    required this.imageUrl,
    this.orderIndex,
  });

  factory ImageInfoModel.fromJson(Map<String, dynamic> json) {
    return ImageInfoModel(
      targetType: json['targetType'],
      imageUrl: json['imageUrl'],
      orderIndex: json['orderIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetType': targetType,
      'imageUrl': imageUrl,
      'orderIndex': orderIndex,
    };
  }
}
