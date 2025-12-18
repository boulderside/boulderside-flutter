import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_summary_response.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/project_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final projectSummaryProvider =
    FutureProvider.autoDispose<ProjectSummaryResponse>((ref) async {
      final service = di<ProjectService>();
      return service.fetchProjectSummary();
    });
