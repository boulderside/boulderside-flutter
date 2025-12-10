import 'package:boulderside_flutter/src/core/user/models/user.dart';

class SocialLoginResult {
  SocialLoginResult({required this.user, required this.isNew});

  final User user;
  final bool isNew;
}
