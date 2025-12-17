class UserMeta {
  const UserMeta({required this.pushEnabled, required this.marketingAgreed});

  final bool pushEnabled;
  final bool marketingAgreed;

  factory UserMeta.fromJson(Map<String, dynamic> json) {
    return UserMeta(
      pushEnabled: json['pushEnabled'] as bool? ?? false,
      marketingAgreed: json['marketingAgreed'] as bool? ?? false,
    );
  }
}
