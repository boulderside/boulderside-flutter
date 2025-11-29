import 'package:boulderside_flutter/widgets/fullscreen_image_gallery.dart';
import 'package:flutter/material.dart';

class BoulderDetailImages extends StatefulWidget {
  const BoulderDetailImages({
    super.key,
    required this.imageUrls,
    this.height = 200,
    this.storageKey = 'boulder_detail_images',
    this.borderRadius = 8.0,
  });

  final List<String> imageUrls;
  final double height;
  final String storageKey;
  final double borderRadius;

  @override
  State<BoulderDetailImages> createState() => _BoulderDetailImagesState();
}

class _BoulderDetailImagesState extends State<BoulderDetailImages> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(keepPage: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              key: PageStorageKey(widget.storageKey),
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (idx) {
                setState(() => _currentPage = idx);
              },
              itemBuilder: (context, index) {
                final url = widget.imageUrls[index];
                return GestureDetector(
                  onTap: () => _openGallery(index),
                  child: Image.network(url, fit: BoxFit.cover),
                );
              },
            ),
            Positioned(
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imageUrls.length, (i) {
                  final isActive = _currentPage == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 8 : 6,
                    height: isActive ? 8 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFFFF3278)
                          : Colors.white70,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGallery(int initialIndex) {
    if (widget.imageUrls.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImageGallery(
          imageUrls: widget.imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}
