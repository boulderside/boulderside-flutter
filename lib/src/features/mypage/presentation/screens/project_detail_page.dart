import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_store.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_routes_screen.dart'
    show ProjectFormSheet;
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/project_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProjectDetailPage extends ConsumerStatefulWidget {
  const ProjectDetailPage({super.key, required this.project});

  final ProjectModel project;

  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage> {
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectStoreProvider.notifier).ensureRouteIndexLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectStoreProvider);
    final project = state.projects.firstWhere(
      (item) => item.projectId == widget.project.projectId,
      orElse: () => widget.project,
    );
    return Scaffold(
      backgroundColor: const Color(0xFF1F2229),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2229),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '프로젝트 상세',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: ProjectFormSheet(
          key: ValueKey(project.projectId),
          completion: project,
          isReadOnly: true,
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Project Edit Button (Full width)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openEditProjectSheet(project),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3278),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                child: const Text(
                  '프로젝트 수정',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12), // Vertical spacing between buttons
            // Project Delete Button (Full width)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isDeleting ? null : () => _handleDelete(project),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                child: _isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white70,
                        ),
                      )
                    : const Text('프로젝트 삭제'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(ProjectModel project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '프로젝트 삭제',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
        ),
        content: Text(
          '“${project.displayTitle}” 프로젝트를 삭제할까요?',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('취소', style: TextStyle(fontFamily: 'Pretendard')),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await ref
          .read(projectStoreProvider.notifier)
          .deleteProject(project.projectId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('프로젝트를 삭제했어요.')));
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제하지 못했습니다: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _openEditProjectSheet(ProjectModel project) async {
    final result = await context.push<bool>(
      AppRoutes.projectForm,
      extra: ProjectFormArguments(completion: project),
    );
    if (result == true && mounted) {
      // Refresh the project list in the store, which will update this screen.
      ref.read(projectStoreProvider.notifier).loadProjects();
    }
  }
}
