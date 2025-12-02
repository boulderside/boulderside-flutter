class GalleryRouteData {
  const GalleryRouteData({
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;
}
