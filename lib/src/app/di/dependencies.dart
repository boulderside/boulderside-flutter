import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/core/api/token_store.dart';
import 'package:boulderside_flutter/src/core/secure_storage.dart';
import 'package:boulderside_flutter/src/core/user/data/services/nickname_service.dart';
import 'package:boulderside_flutter/src/core/user/data/services/user_block_service.dart';
import 'package:boulderside_flutter/src/core/user/stores/user_store.dart';
import 'package:boulderside_flutter/src/features/boulder/data/services/approach_service.dart';
import 'package:boulderside_flutter/src/features/boulder/data/services/weather_service.dart';
import 'package:boulderside_flutter/src/features/community/data/services/board_post_service.dart';
import 'package:boulderside_flutter/src/features/community/data/services/comment_service.dart';
import 'package:boulderside_flutter/src/features/community/data/services/mate_post_service.dart';
import 'package:boulderside_flutter/src/features/home/data/cache/route_index_cache.dart';
import 'package:boulderside_flutter/src/features/home/data/repositories/boulder_repository_impl.dart';
import 'package:boulderside_flutter/src/features/home/data/repositories/like_repository_impl.dart';
import 'package:boulderside_flutter/src/features/home/data/repositories/rec_boulder_repository_impl.dart';
import 'package:boulderside_flutter/src/features/home/data/repositories/route_repository_impl.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_detail_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/rec_boulder_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_detail_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/boulder_repository.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/like_repository.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/rec_boulder_repository.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/route_repository.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_rec_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_routes_use_case.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_boulder_like_use_case.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_route_like_use_case.dart';
import 'package:boulderside_flutter/src/features/map/data/repositories/map_repository_impl.dart';
import 'package:boulderside_flutter/src/features/map/domain/repositories/map_repository.dart';
import 'package:boulderside_flutter/src/features/map/domain/usecases/fetch_map_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/login/data/repositories/auth_repository_impl.dart';
import 'package:boulderside_flutter/src/features/login/data/services/oauth_login_service.dart';
import 'package:boulderside_flutter/src/features/login/data/services/oauth_signup_service.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';
import 'package:boulderside_flutter/src/features/mypage/data/repositories/my_comments_repository_impl.dart';
import 'package:boulderside_flutter/src/features/mypage/data/repositories/project_repository_impl.dart';
import 'package:boulderside_flutter/src/features/mypage/data/repositories/my_likes_repository_impl.dart';
import 'package:boulderside_flutter/src/features/mypage/data/repositories/my_posts_repository_impl.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/my_comments_service.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/my_likes_service.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/my_posts_service.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/notice_service.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/project_service.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/report_service.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/completion_service.dart';
import 'package:boulderside_flutter/src/features/search/data/services/search_service.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_comments_repository.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_likes_repository.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_posts_repository.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/project_repository.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/create_project_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/delete_project_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_project_by_route_id_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_liked_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_liked_routes_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_my_comments_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_my_board_posts_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_my_mate_posts_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_projects_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/update_project_use_case.dart';

final GetIt di = GetIt.instance;

void configureDependencies() {
  if (di.isRegistered<Dio>()) {
    return;
  }

  di.registerLazySingleton<TokenStore>(() => SecureTokenStore(SecureStorage()));
  di.registerLazySingleton<UserStore>(() => UserStore(di()));

  di.registerLazySingleton<Dio>(() => ApiClient.dio);

  di.registerLazySingleton<BoulderService>(() => BoulderService(di()));
  di.registerLazySingleton<RecBoulderService>(() => RecBoulderService(di()));
  di.registerLazySingleton<RouteService>(() => RouteService(di()));
  di.registerLazySingleton<RouteDetailService>(() => RouteDetailService(di()));
  di.registerLazySingleton<BoulderDetailService>(
    () => BoulderDetailService(di()),
  );
  di.registerLazySingleton<ApproachService>(() => ApproachService(di()));
  di.registerLazySingleton<WeatherService>(() => WeatherService(di()));
  di.registerLazySingleton<LikeService>(() => LikeService(di()));
  di.registerLazySingleton<ProjectService>(() => ProjectService(di()));
  di.registerLazySingleton<CompletionService>(() => CompletionService(di()));
  di.registerLazySingleton<MyLikesService>(() => MyLikesService(di()));
  di.registerLazySingleton<MyPostsService>(() => MyPostsService(di()));
  di.registerLazySingleton<MyCommentsService>(() => MyCommentsService(di()));
  di.registerLazySingleton<ReportService>(() => ReportService(di()));
  di.registerLazySingleton<NoticeService>(() => NoticeService(di()));
  di.registerLazySingleton<MatePostService>(() => MatePostService());
  di.registerLazySingleton<BoardPostService>(() => BoardPostService());
  di.registerLazySingleton<CommentService>(() => CommentService());
  di.registerLazySingleton<SearchService>(() => SearchService());
  di.registerLazySingleton<NicknameService>(() => NicknameService());
  di.registerLazySingleton<UserBlockService>(() => UserBlockService(di()));

  di.registerLazySingleton<BoulderRepository>(
    () => BoulderRepositoryImpl(di()),
  );
  di.registerLazySingleton<RouteRepository>(() => RouteRepositoryImpl(di()));
  di.registerLazySingleton<RecBoulderRepository>(
    () => RecBoulderRepositoryImpl(di()),
  );
  di.registerLazySingleton<LikeRepository>(() => LikeRepositoryImpl(di()));
  di.registerLazySingleton<MapRepository>(() => MapRepositoryImpl(di()));
  di.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(di()),
  );
  di.registerLazySingleton<MyLikesRepository>(
    () => MyLikesRepositoryImpl(di()),
  );
  di.registerLazySingleton<MyPostsRepository>(
    () => MyPostsRepositoryImpl(di()),
  );
  di.registerLazySingleton<MyCommentsRepository>(
    () => MyCommentsRepositoryImpl(di()),
  );
  di.registerLazySingleton<OAuthLoginService>(() => OAuthLoginService());
  di.registerLazySingleton<OAuthSignupService>(() => OAuthSignupService());
  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(di(), di(), di(), di(), di()),
  );

  di.registerLazySingleton(() => FetchBouldersUseCase(di()));
  di.registerLazySingleton(() => FetchRecBouldersUseCase(di()));
  di.registerLazySingleton(() => FetchRoutesUseCase(di()));
  di.registerLazySingleton(() => ToggleBoulderLikeUseCase(di()));
  di.registerLazySingleton(() => ToggleRouteLikeUseCase(di()));
  di.registerLazySingleton(() => FetchMapBouldersUseCase(di()));
  di.registerLazySingleton(() => FetchProjectsUseCase(di()));
  di.registerLazySingleton(() => FetchLikedRoutesUseCase(di()));
  di.registerLazySingleton(() => FetchLikedBouldersUseCase(di()));
  di.registerLazySingleton(() => FetchMyBoardPostsUseCase(di()));
  di.registerLazySingleton(() => FetchMyMatePostsUseCase(di()));
  di.registerLazySingleton(() => FetchMyCommentsUseCase(di()));
  di.registerLazySingleton(() => CreateProjectUseCase(di()));
  di.registerLazySingleton(() => FetchProjectByRouteIdUseCase(di()));
  di.registerLazySingleton(() => UpdateProjectUseCase(di()));
  di.registerLazySingleton(() => DeleteProjectUseCase(di()));
  di.registerLazySingleton<RouteIndexCache>(() => RouteIndexCache(di()));
}
