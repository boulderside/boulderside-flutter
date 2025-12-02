import 'package:boulderside_flutter/src/features/login/presentation/viewmodels/login_view_model.dart';
import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class LoginProviders extends StatelessWidget {
  const LoginProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>(
      create: (_) => di<LoginViewModel>(),
      child: child,
    );
  }
}
