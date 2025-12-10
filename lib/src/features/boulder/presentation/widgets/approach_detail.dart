import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/shared/navigation/gallery_route_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApproachDetail extends StatelessWidget {
  final List<ApproachItem> items;

  // 디자인 옵션(필요시 조절)
  final double imageHeight;
  final double imageWidth;
  final double imageGap;
  final double contentLeftIndent;

  const ApproachDetail({
    super.key,
    required this.items,
    this.imageHeight = 200,
    this.imageWidth = 300,
    this.imageGap = 15,
    this.contentLeftIndent = 45,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (i) {
        final item = items[i];
        final index = i + 1;

        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF3B4352),
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 2,
                            margin: const EdgeInsetsDirectional.fromSTEB(
                              0,
                              10,
                              0,
                              10,
                            ),
                            color: const Color(0x33FFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: contentLeftIndent - 24 > 0
                      ? contentLeftIndent - 24
                      : 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 번호 원 + 제목
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          2,
                          10,
                          0,
                        ),
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 가로 스크롤 이미지
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          0,
                          10,
                          10,
                        ),
                        child: SizedBox(
                          height: imageHeight,
                          child: item.imageUrls.isEmpty
                              ? _ApproachImagePlaceholder(
                                  width: imageWidth,
                                  height: imageHeight,
                                )
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: item.imageUrls.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(width: imageGap),
                                  itemBuilder: (context, j) {
                                    final imageUrl = item.imageUrls[j];
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: GestureDetector(
                                        onTap: () => _openGallery(
                                          context,
                                          item.imageUrls,
                                          j,
                                        ),
                                        child: Image.network(
                                          imageUrl,
                                          width: imageWidth,
                                          height: imageHeight,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),

                      if (item.description != null &&
                          item.description!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            0,
                            0,
                            10,
                            6,
                          ),
                          child: Text(
                            item.description!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      if (item.note != null && item.note!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            0,
                            0,
                            10,
                            10,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x22FFFFFF), // 회색 배경
                                border: Border.all(
                                  color: const Color(0x22FFFFFF),
                                ),
                              ),
                              child: Text(
                                item.note!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class ApproachItem {
  final String title;
  final List<String> imageUrls;
  final String? description;
  final String? note;

  const ApproachItem({
    required this.title,
    required this.imageUrls,
    this.description,
    this.note,
  });
}

class _ApproachImagePlaceholder extends StatelessWidget {
  const _ApproachImagePlaceholder({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2F3440),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.photo, color: Color(0xFF7C7C7C), size: 32),
      ),
    );
  }
}

void _openGallery(
  BuildContext context,
  List<String> imageUrls,
  int initialIndex,
) {
  if (imageUrls.isEmpty) {
    return;
  }

  context.push(
    AppRoutes.gallery,
    extra: GalleryRouteData(imageUrls: imageUrls, initialIndex: initialIndex),
  );
}
