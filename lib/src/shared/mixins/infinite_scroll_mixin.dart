import 'package:flutter/widgets.dart';

mixin InfiniteScrollMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();

  double scrollThreshold = 200;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    super.dispose();
  }

  bool get canLoadMore => true;

  Future<void> onNearBottom();

  void _handleScroll() {
    if (!canLoadMore) return;
    final position = scrollController.position;
    if (!position.hasPixels || !position.hasViewportDimension) return;
    final threshold = position.maxScrollExtent - scrollThreshold;
    if (position.pixels >= threshold) {
      onNearBottom();
    }
  }
}
