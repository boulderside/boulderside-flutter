import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/notifications/models/app_notification.dart';
import 'package:boulderside_flutter/src/core/notifications/stores/notification_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationStoreProvider =
    StateNotifierProvider<NotificationStore, List<AppNotification>>(
      (ref) => di<NotificationStore>(),
    );
