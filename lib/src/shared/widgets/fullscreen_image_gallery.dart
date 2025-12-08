import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenImageGallery extends StatefulWidget {
  const FullScreenImageGallery({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              pageController: _controller,
              itemCount: widget.imageUrls.length,
              builder: (context, index) {
                final url = widget.imageUrls[index];
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(url),
                  heroAttributes: PhotoViewHeroAttributes(tag: url),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2.5,
                );
              },
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              loadingBuilder: (context, progress) {
                final value =
                    progress == null || progress.expectedTotalBytes == null
                    ? null
                    : progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!;
                return Center(
                  child: CircularProgressIndicator(
                    value: value,
                    color: Colors.white,
                  ),
                );
              },
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Colors.white70,
                  size: 32,
                ),
                onPressed: () => context.pop(),
              ),
            ),
            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
