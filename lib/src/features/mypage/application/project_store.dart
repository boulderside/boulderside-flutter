import 'dart:async';

import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/cache/route_index_cache.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_attempt_history_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/create_project_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/delete_project_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_project_by_route_id_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_projects_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/update_project_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectStore extends StateNotifier<ProjectState> {
  ProjectStore(
    this._fetchProjects,
    this._createProject,
    this._updateProject,
    this._deleteProject,
    this._fetchProjectByRouteId,
    this._routeIndexCache,
  ) : super(const ProjectState());

  final FetchProjectsUseCase _fetchProjects;
  final CreateProjectUseCase _createProject;
  final UpdateProjectUseCase _updateProject;
  final DeleteProjectUseCase _deleteProject;
  final FetchProjectByRouteIdUseCase _fetchProjectByRouteId;
  final RouteIndexCache _routeIndexCache;

  Future<void> loadProjects() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final Result<List<ProjectModel>> result = await _fetchProjects();
    result.when(
      success: (items) {
        state = state.copyWith(
          projects: items.map(_attachRoute).toList(),
          isLoading: false,
          errorMessage: null,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          projects: const <ProjectModel>[],
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
    if (state.routeIndexMap.isEmpty && !state.isRouteIndexLoading) {
      unawaited(ensureRouteIndexLoaded());
    }
  }

  Future<void> refresh() => loadProjects();

  Future<void> ensureRouteIndexLoaded() async {
    if (state.routeIndexMap.isNotEmpty || state.isRouteIndexLoading) {
      return;
    }
    state = state.copyWith(isRouteIndexLoading: true, routeIndexError: null);
    try {
      final routes = await _routeIndexCache.load();
      final map = {for (final route in routes) route.id: route};
      state = state.copyWith(
        routeIndexList: routes,
        routeIndexMap: map,
        isRouteIndexLoading: false,
        routeIndexError: null,
      );
      _syncProjectsWithRoutes();
    } catch (error) {
      state = state.copyWith(
        isRouteIndexLoading: false,
        routeIndexError: '루트 목록을 불러오지 못했습니다.',
      );
    }
  }

  Future<void> addProject({
    required int routeId,
    required bool completed,
    String? memo,
    List<ProjectAttemptHistoryModel> attemptHistories =
        const <ProjectAttemptHistoryModel>[],
  }) async {
    await _mutate(() async {
      final Result<ProjectModel> result = await _createProject(
        routeId: routeId,
        completed: completed,
        memo: memo,
        attemptHistories: attemptHistories,
      );
      result.when(
        success: (project) {
          final enriched = _attachRoute(project);
          final projects = <ProjectModel>[
            enriched,
            ...state.projects.where((item) => item.routeId != enriched.routeId),
          ];
          state = state.copyWith(projects: projects, errorMessage: null);
        },
        failure: _handleFailure,
      );
    });
  }

  Future<void> updateProject({
    required int projectId,
    required bool completed,
    String? memo,
    List<ProjectAttemptHistoryModel> attemptHistories =
        const <ProjectAttemptHistoryModel>[],
  }) async {
    await _mutate(() async {
      final Result<ProjectModel> result = await _updateProject(
        projectId: projectId,
        completed: completed,
        memo: memo,
        attemptHistories: attemptHistories,
      );
      result.when(
        success: (project) {
          final enriched = _attachRoute(project);
          final projects = List<ProjectModel>.from(state.projects);
          final index = projects.indexWhere(
            (item) => item.projectId == enriched.projectId,
          );
          if (index >= 0) {
            projects[index] = enriched;
          } else {
            projects.insert(0, enriched);
          }
          state = state.copyWith(projects: projects, errorMessage: null);
        },
        failure: _handleFailure,
      );
    });
  }

  Future<void> deleteProject(int projectId) async {
    await _mutate(() async {
      final Result<void> result = await _deleteProject(projectId);
      result.when(
        success: (_) {
          final projects = state.projects
              .where((item) => item.projectId != projectId)
              .toList();
          state = state.copyWith(projects: projects, errorMessage: null);
        },
        failure: _handleFailure,
      );
    });
  }

  Future<ProjectModel?> fetchProjectByRoute(int routeId) async {
    final Result<ProjectModel?> result = await _fetchProjectByRouteId(routeId);
    ProjectModel? project;
    result.when(
      success: (value) {
        project = value;
        if (value != null) {
          final enriched = _attachRoute(value);
          final projects = List<ProjectModel>.from(state.projects);
          final index = projects.indexWhere(
            (item) => item.projectId == enriched.projectId,
          );
          if (index >= 0) {
            projects[index] = enriched;
          } else {
            projects.insert(0, enriched);
          }
          state = state.copyWith(projects: projects);
        }
      },
      failure: (_) {},
    );
    return project;
  }

  RouteModel? routeById(int routeId) => state.routeIndexMap[routeId];

  Future<void> _mutate(Future<void> Function() action) async {
    state = state.copyWith(isMutating: true);
    try {
      await action();
    } finally {
      state = state.copyWith(isMutating: false);
    }
  }

  ProjectModel _attachRoute(ProjectModel project) {
    final route = state.routeIndexMap[project.routeId];
    if (route == null || project.route == route) {
      return project;
    }
    return project.copyWith(route: route);
  }

  void _syncProjectsWithRoutes() {
    if (state.routeIndexMap.isEmpty) return;
    final synced = state.projects.map(_attachRoute).toList();
    state = state.copyWith(projects: synced);
  }

  Never _handleFailure(AppFailure failure) {
    state = state.copyWith(errorMessage: failure.message);
    throw failure;
  }
}

class ProjectState {
  const ProjectState({
    this.projects = const <ProjectModel>[],
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
    this.routeIndexList = const <RouteModel>[],
    this.routeIndexMap = const <int, RouteModel>{},
    this.isRouteIndexLoading = false,
    this.routeIndexError,
  });

  final List<ProjectModel> projects;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;
  final List<RouteModel> routeIndexList;
  final Map<int, RouteModel> routeIndexMap;
  final bool isRouteIndexLoading;
  final String? routeIndexError;

  List<RouteModel> get availableRoutes => routeIndexList;

  ProjectState copyWith({
    List<ProjectModel>? projects,
    bool? isLoading,
    bool? isMutating,
    String? errorMessage,
    List<RouteModel>? routeIndexList,
    Map<int, RouteModel>? routeIndexMap,
    bool? isRouteIndexLoading,
    String? routeIndexError,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: errorMessage ?? this.errorMessage,
      routeIndexList: routeIndexList ?? this.routeIndexList,
      routeIndexMap: routeIndexMap ?? this.routeIndexMap,
      isRouteIndexLoading: isRouteIndexLoading ?? this.isRouteIndexLoading,
      routeIndexError: routeIndexError ?? this.routeIndexError,
    );
  }
}

final fetchProjectsUseCaseProvider = Provider<FetchProjectsUseCase>(
  (ref) => di<FetchProjectsUseCase>(),
);

final createProjectUseCaseProvider = Provider<CreateProjectUseCase>(
  (ref) => di<CreateProjectUseCase>(),
);

final updateProjectUseCaseProvider = Provider<UpdateProjectUseCase>(
  (ref) => di<UpdateProjectUseCase>(),
);

final deleteProjectUseCaseProvider = Provider<DeleteProjectUseCase>(
  (ref) => di<DeleteProjectUseCase>(),
);

final fetchProjectByRouteIdUseCaseProvider =
    Provider<FetchProjectByRouteIdUseCase>(
      (ref) => di<FetchProjectByRouteIdUseCase>(),
    );

final routeIndexCacheProvider = Provider<RouteIndexCache>(
  (ref) => di<RouteIndexCache>(),
);

final projectStoreProvider = StateNotifierProvider<ProjectStore, ProjectState>((
  ref,
) {
  return ProjectStore(
    ref.watch(fetchProjectsUseCaseProvider),
    ref.watch(createProjectUseCaseProvider),
    ref.watch(updateProjectUseCaseProvider),
    ref.watch(deleteProjectUseCaseProvider),
    ref.watch(fetchProjectByRouteIdUseCaseProvider),
    ref.watch(routeIndexCacheProvider),
  );
});
