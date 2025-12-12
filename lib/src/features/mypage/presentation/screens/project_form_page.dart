import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_routes_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProjectFormArguments {
  final ProjectModel? completion;
  final RouteModel? initialRoute;

  ProjectFormArguments({this.completion, this.initialRoute});
}

class ProjectFormPage extends ConsumerStatefulWidget {
  const ProjectFormPage({super.key, required this.args});

  final ProjectFormArguments args;

  @override
  ConsumerState<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends ConsumerState<ProjectFormPage> {
  final GlobalKey<ProjectFormSheetState> _formKey =
      GlobalKey<ProjectFormSheetState>();

  @override
  Widget build(BuildContext context) {
    final title = widget.args.completion == null ? '프로젝트 등록' : '프로젝트 수정';
    return Scaffold(
      backgroundColor: const Color(0xFF1F2229),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2229),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _formKey.currentState?.submit(context),
            child: const Text(
              '완료',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Color(0xFFFF3278),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ProjectFormSheet(
          key: _formKey,
          completion: widget.args.completion,
          initialRoute: widget.args.initialRoute,
          isReadOnly: false,
          showSubmitButton: false,
        ),
      ),
    );
  }
}
