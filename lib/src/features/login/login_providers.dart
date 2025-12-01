import 'package:boulderside_flutter/src/core/user/stores/user_store.dart';
import 'package:boulderside_flutter/src/features/login/data/services/login_service.dart';
import 'package:boulderside_flutter/src/features/login/presentation/viewmodels/login_view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class LoginProviders extends StatelessWidget {
  const LoginProviders({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>(
      create: (_) => LoginViewModel(
        context.read<LoginService>(),
        context.read<UserStore>(),
      ),
      child: child,
    );
  }
}
