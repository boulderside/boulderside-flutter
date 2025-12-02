import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/core/api/token_store.dart';
import 'package:boulderside_flutter/src/core/secure_storage.dart';
import 'package:boulderside_flutter/src/core/user/stores/user_store.dart';
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
import 'package:boulderside_flutter/src/features/home/presentation/viewmodels/boulder_list_view_model.dart';
import 'package:boulderside_flutter/src/features/home/presentation/viewmodels/rec_boulder_list_view_model.dart';
import 'package:boulderside_flutter/src/features/home/presentation/viewmodels/route_list_view_model.dart';
import 'package:boulderside_flutter/src/features/map/data/repositories/map_repository_impl.dart';
import 'package:boulderside_flutter/src/features/map/domain/repositories/map_repository.dart';
import 'package:boulderside_flutter/src/features/map/domain/usecases/fetch_map_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/map/presentation/viewmodels/map_view_model.dart';
import 'package:boulderside_flutter/src/features/login/data/repositories/auth_repository_impl.dart';
import 'package:boulderside_flutter/src/features/login/data/services/login_service.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';
import 'package:boulderside_flutter/src/features/login/domain/usecases/login_with_email_use_case.dart';
import 'package:boulderside_flutter/src/features/login/presentation/viewmodels/login_view_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/repositories/route_completion_repository_impl.dart';
import 'package:boulderside_flutter/src/features/mypage/data/repositories/my_likes_repository_impl.dart';
import 'package:boulderside_flutter/src/features/mypage/data/repositories/my_posts_repository_impl.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/my_likes_service.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/my_posts_service.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/route_completion_service.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_likes_repository.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_posts_repository.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/route_completion_repository.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/create_route_completion_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/delete_route_completion_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_liked_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_liked_routes_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_my_board_posts_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_my_mate_posts_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_route_completions_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/update_route_completion_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/viewmodels/my_likes_view_model.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/viewmodels/my_posts_view_model.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/viewmodels/route_completion_view_model.dart';

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
  di.registerLazySingleton<LikeService>(() => LikeService(di()));
  di.registerLazySingleton<RouteCompletionService>(
    () => RouteCompletionService(di()),
  );
  di.registerLazySingleton<MyLikesService>(() => MyLikesService(di()));
  di.registerLazySingleton<MyPostsService>(() => MyPostsService(di()));
  di.registerLazySingleton<LoginService>(() => LoginService());

  di.registerLazySingleton<BoulderRepository>(
    () => BoulderRepositoryImpl(di()),
  );
  di.registerLazySingleton<RouteRepository>(() => RouteRepositoryImpl(di()));
  di.registerLazySingleton<RecBoulderRepository>(
    () => RecBoulderRepositoryImpl(di()),
  );
  di.registerLazySingleton<LikeRepository>(() => LikeRepositoryImpl(di()));
  di.registerLazySingleton<MapRepository>(() => MapRepositoryImpl(di()));
  di.registerLazySingleton<RouteCompletionRepository>(
    () => RouteCompletionRepositoryImpl(di()),
  );
  di.registerLazySingleton<MyLikesRepository>(
    () => MyLikesRepositoryImpl(di()),
  );
  di.registerLazySingleton<MyPostsRepository>(
    () => MyPostsRepositoryImpl(di()),
  );
  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(di(), di(), di()),
  );

  di.registerLazySingleton(() => FetchBouldersUseCase(di()));
  di.registerLazySingleton(() => FetchRecBouldersUseCase(di()));
  di.registerLazySingleton(() => FetchRoutesUseCase(di()));
  di.registerLazySingleton(() => ToggleBoulderLikeUseCase(di()));
  di.registerLazySingleton(() => ToggleRouteLikeUseCase(di()));
  di.registerLazySingleton(() => FetchMapBouldersUseCase(di()));
  di.registerLazySingleton(() => FetchRouteCompletionsUseCase(di()));
  di.registerLazySingleton(() => FetchLikedRoutesUseCase(di()));
  di.registerLazySingleton(() => FetchLikedBouldersUseCase(di()));
  di.registerLazySingleton(() => FetchMyBoardPostsUseCase(di()));
  di.registerLazySingleton(() => FetchMyMatePostsUseCase(di()));
  di.registerLazySingleton(() => CreateRouteCompletionUseCase(di()));
  di.registerLazySingleton(() => UpdateRouteCompletionUseCase(di()));
  di.registerLazySingleton(() => DeleteRouteCompletionUseCase(di()));
  di.registerLazySingleton(() => LoginWithEmailUseCase(di()));

  di.registerFactory(() => BoulderListViewModel(di()));
  di.registerFactory(() => RouteListViewModel(di()));
  di.registerFactory(() => RecBoulderListViewModel(di()));
  di.registerFactory(() => MapViewModel(di()));
  di.registerFactory(() => MyLikesViewModel(di(), di(), di(), di()));
  di.registerFactory(() => MyPostsViewModel(di(), di()));
  di.registerFactory(
    () =>
        RouteCompletionViewModel(di(), di(), di(), di(), di<RouteIndexCache>()),
  );
  di.registerFactory(() => LoginViewModel(di()));

  di.registerLazySingleton<RouteIndexCache>(() => RouteIndexCache(di()));
}
