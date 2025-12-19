import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/completion_response.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/completion_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final completionByRouteProvider = FutureProvider.autoDispose
    .family<CompletionResponse?, int>((ref, routeId) async {
      final service = di<CompletionService>();
      return service.fetchCompletionByRoute(routeId);
    });

final completionsByLevelProvider = FutureProvider.autoDispose
    .family<List<CompletionResponse>, String>((ref, level) async {
      final service = di<CompletionService>();
      return service.fetchCompletionsByLevel(level);
    });

final completionsByDateProvider = FutureProvider.autoDispose
    .family<List<CompletionResponse>, DateTime>((ref, date) async {
      final service = di<CompletionService>();
      return service.fetchCompletionsByDate(date);
    });
