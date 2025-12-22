class Instagram {
  const Instagram({
    required this.id,
    required this.url,
    required this.routeIds,
    this.createdAt,
  });

  final int id;
  final String url;
  final List<int> routeIds;
  final DateTime? createdAt;

  Instagram copyWith({
    int? id,
    String? url,
    List<int>? routeIds,
    DateTime? createdAt,
  }) {
    return Instagram(
      id: id ?? this.id,
      url: url ?? this.url,
      routeIds: routeIds ?? this.routeIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
