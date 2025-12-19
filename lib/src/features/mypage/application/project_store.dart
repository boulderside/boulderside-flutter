import 'dart:async';

import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/cache/route_index_cache.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_summary_provider.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_session_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/project_sort_type.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/create_project_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/delete_project_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_project_by_route_id_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_projects_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/update_project_use_case.dart';
import 'package:boulderside_flutter/src/features/route/application/route_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ProjectFilter {
  all(null, '전체'),
  trying(false, '진행중'),
  done(true, '완등');

  const ProjectFilter(this.isCompleted, this.label);
  final bool? isCompleted;
  final String label;
}

class ProjectStore extends StateNotifier<ProjectState> {
  ProjectStore(
    this._ref,
    this._fetchProjects,
    this._createProject,
    this._updateProject,
    this._deleteProject,
    this._fetchProjectByRouteId,
    this._routeIndexCache,
    this._updateRouteInStore,
  ) : super(const ProjectState());

  final Ref _ref;
  final FetchProjectsUseCase _fetchProjects;
  final CreateProjectUseCase _createProject;
  final UpdateProjectUseCase _updateProject;
  final DeleteProjectUseCase _deleteProject;
  final FetchProjectByRouteIdUseCase _fetchProjectByRouteId;
  final RouteIndexCache _routeIndexCache;
  final void Function(RouteModel) _updateRouteInStore;

  Future<void> loadProjects() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final Result<List<ProjectModel>> result = await _fetchProjects(
      isCompleted: state.activeFilter.isCompleted,
      sortType: ProjectSortType.latestUpdated,
    );
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

  Future<void> setFilter(ProjectFilter filter) async {
    if (state.activeFilter == filter) return;
    state = state.copyWith(activeFilter: filter);
    await loadProjects();
  }

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
    List<ProjectSessionModel> sessions = const <ProjectSessionModel>[],
  }) async {
    await _mutate(() async {
      final Result<ProjectModel> result = await _createProject(
        routeId: routeId,
        completed: completed,
        memo: memo,
        sessions: sessions,
      );
      result.when(
        success: (project) {
          final enriched = _attachRoute(project);
          final matchesFilter =
              state.activeFilter.isCompleted == null ||
              project.completed == state.activeFilter.isCompleted;

          if (matchesFilter) {
            final projects = <ProjectModel>[
              enriched,
              ...state.projects.where(
                (item) => item.routeId != enriched.routeId,
              ),
            ];
            state = state.copyWith(projects: projects, errorMessage: null);
          }

          // Update route cache immediately with project's routeInfo
          _updateRouteFromProject(project);
          _refreshProjectSummary();
        },
        failure: _handleFailure,
      );
    });
  }

  Future<void> updateProject({
    required int projectId,
    required bool completed,
    String? memo,
    List<ProjectSessionModel> sessions = const <ProjectSessionModel>[],
  }) async {
    await _mutate(() async {
      final Result<ProjectModel> result = await _updateProject(
        projectId: projectId,
        completed: completed,
        memo: memo,
        sessions: sessions,
      );
      result.when(
        success: (project) {
          final enriched = _attachRoute(project);
          final projects = List<ProjectModel>.from(state.projects);
          final index = projects.indexWhere(
            (item) => item.projectId == enriched.projectId,
          );

          final matchesFilter =
              state.activeFilter.isCompleted == null ||
              project.completed == state.activeFilter.isCompleted;

          if (index >= 0) {
            if (matchesFilter) {
              projects[index] = enriched;
            } else {
              projects.removeAt(index);
            }
          } else if (matchesFilter) {
            projects.insert(0, enriched);
          }
          state = state.copyWith(projects: projects, errorMessage: null);

          // Update route cache immediately with project's routeInfo
          _updateRouteFromProject(project);
          _refreshProjectSummary();
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
          _refreshProjectSummary();
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
        final projects = List<ProjectModel>.from(state.projects);
        final index = projects.indexWhere((item) => item.routeId == routeId);

        if (value != null) {
          final enriched = _attachRoute(value);
          final matchesFilter =
              state.activeFilter.isCompleted == null ||
              enriched.completed == state.activeFilter.isCompleted;

          if (index >= 0) {
            if (matchesFilter) {
              projects[index] = enriched;
            } else {
              projects.removeAt(index);
            }
          } else if (matchesFilter) {
            projects.insert(0, enriched);
          }
        } else if (index >= 0) {
          projects.removeAt(index);
        }

        state = state.copyWith(projects: projects);
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
    // routeInfo is now included in the API response, no need to attach separately
    return project;
  }

  void _syncProjectsWithRoutes() {
    if (state.routeIndexMap.isEmpty) return;
    final synced = state.projects.map(_attachRoute).toList();
    state = state.copyWith(projects: synced);
  }

  void _updateRouteFromProject(ProjectModel project) {
    // Update route cache with data from project's routeInfo
    if (project.routeInfo != null && state.routeIndexMap.isNotEmpty) {
      final routeInfo = project.routeInfo!;
      _routeIndexCache.updateRoute(project.routeId, (route) {
        return route.copyWith(
          climberCount: routeInfo.climberCount,
          likeCount: routeInfo.likeCount,
          viewCount: routeInfo.viewCount,
          commentCount: routeInfo.commentCount,
        );
      });

      // Update state with the new route data
      final updatedRoute = state.routeIndexMap[project.routeId];
      if (updatedRoute != null) {
        final updatedMap = Map<int, RouteModel>.from(state.routeIndexMap);
        final newRoute = updatedRoute.copyWith(
          climberCount: routeInfo.climberCount,
          likeCount: routeInfo.likeCount,
          viewCount: routeInfo.viewCount,
          commentCount: routeInfo.commentCount,
        );
        updatedMap[project.routeId] = newRoute;
        final updatedList = state.routeIndexList.map((route) {
          return route.id == project.routeId ? newRoute : route;
        }).toList();
        state = state.copyWith(
          routeIndexMap: updatedMap,
          routeIndexList: updatedList,
        );

        // Also update RouteStore to ensure UI reflects the changes
        _updateRouteInStore(newRoute);
      }
    }
  }

  Never _handleFailure(AppFailure failure) {
    state = state.copyWith(errorMessage: failure.message);
    throw failure;
  }

  void _refreshProjectSummary() {
    _ref.invalidate(projectSummaryProvider);
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
    this.activeFilter = ProjectFilter.all,
  });

  final List<ProjectModel> projects;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;
  final List<RouteModel> routeIndexList;
  final Map<int, RouteModel> routeIndexMap;
  final bool isRouteIndexLoading;
  final String? routeIndexError;
  final ProjectFilter activeFilter;

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
    ProjectFilter? activeFilter,
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
      activeFilter: activeFilter ?? this.activeFilter,
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

final projectStoreProvider = StateNotifierProvider<ProjectStore, ProjectState>(
  (ref) {
  // Callback to update RouteStore when project changes affect route data
  void updateRouteInStore(RouteModel route) {
    ref.read(routeStoreProvider.notifier).upsertRoute(route);
  }

  return ProjectStore(
    ref,
    ref.watch(fetchProjectsUseCaseProvider),
    ref.watch(createProjectUseCaseProvider),
    ref.watch(updateProjectUseCaseProvider),
    ref.watch(deleteProjectUseCaseProvider),
    ref.watch(fetchProjectByRouteIdUseCaseProvider),
    ref.watch(routeIndexCacheProvider),
    updateRouteInStore,
  );
  },
);
