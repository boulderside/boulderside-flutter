import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/notifications/models/notice_notification.dart';
import 'package:boulderside_flutter/src/core/notifications/stores/notice_notification_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final noticeNotificationStoreProvider =
    StateNotifierProvider<NoticeNotificationStore, List<NoticeNotification>>(
      (ref) => di<NoticeNotificationStore>(),
    );
