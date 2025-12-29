import 'dart:convert';

import 'package:boulderside_flutter/src/core/notifications/models/app_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationStore extends StateNotifier<List<AppNotification>> {
  NotificationStore() : super(const []);

  static const String _storageKey = 'notice_notifications';
  static const int _maxItems = 50;
  static const String _activeUserIdKey = 'notice_notifications_active_user_id';

  Future<void> load() async {
    final userId = await _getActiveUserId();
    if (userId == null || userId.isEmpty) {
      state = const [];
      return;
    }
    state = await _loadItems(userId);
  }

  Future<void> add(AppNotification item) async {
    state = await persistNotification(item);
  }

  Future<void> markAllRead() async {
    final userId = await _getActiveUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }
    final current = await _loadItems(userId);
    if (current.isEmpty || current.every((item) => item.isRead)) {
      return;
    }
    final next = current.map((item) => item.copyWith(isRead: true)).toList();
    await _saveItems(next, userId);
    state = next;
  }

  Future<void> markReadById(String id) async {
    if (id.isEmpty) {
      return;
    }
    final userId = await _getActiveUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }
    final current = await _loadItems(userId);
    final index = current.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    final target = current[index];
    if (target.isRead) {
      return;
    }
    final next = [...current];
    next[index] = target.copyWith(isRead: true);
    await _saveItems(next, userId);
    state = next;
  }

  Future<void> removeById(String id) async {
    if (id.isEmpty) {
      return;
    }
    final userId = await _getActiveUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }
    final current = await _loadItems(userId);
    final next = current.where((item) => item.id != id).toList();
    await _saveItems(next, userId);
    state = next;
  }

  Future<void> clear() async {
    final userId = await _getActiveUserId();
    if (userId != null && userId.isNotEmpty) {
      await _saveItems(const [], userId);
    }
    state = const [];
  }

  static Future<List<AppNotification>> persistNotification(
    AppNotification item, {
    String? userId,
  }) async {
    final resolvedUserId = userId ?? await _getActiveUserId();
    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      return const [];
    }
    final current = await _loadItems(resolvedUserId);
    final next = _merge(item, current);
    await _saveItems(next, resolvedUserId);
    return next;
  }

  static Future<void> setActiveUserId(String userId) async {
    if (userId.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUserIdKey, userId);
    await _migrateLegacyItems(userId);
  }

  static Future<String?> _getActiveUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_activeUserIdKey);
    } catch (error) {
      debugPrint('알림 사용자 키 로드 실패: $error');
      return null;
    }
  }

  static List<AppNotification> _merge(
    AppNotification item,
    List<AppNotification> existing,
  ) {
    final filtered = existing.where((e) => e.id != item.id).toList();
    final merged = [item, ...filtered];
    return merged.length > _maxItems ? merged.sublist(0, _maxItems) : merged;
  }

  static Future<List<AppNotification>> _loadItems(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKeyForUser(userId));
      if (raw == null || raw.isEmpty) {
        return const [];
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map(AppNotification.fromJson)
          .toList();
    } catch (error) {
      debugPrint('알림 목록 로드 실패: $error');
      return const [];
    }
  }

  static Future<void> _saveItems(
    List<AppNotification> items,
    String userId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKeyForUser(userId), encoded);
    } catch (error) {
      debugPrint('알림 목록 저장 실패: $error');
    }
  }

  static String _storageKeyForUser(String userId) => '${_storageKey}_$userId';

  static Future<void> _migrateLegacyItems(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        await prefs.remove(_storageKey);
        return;
      }
      final legacyItems = decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map(AppNotification.fromJson)
          .toList();
      if (legacyItems.isEmpty) {
        await prefs.remove(_storageKey);
        return;
      }
      final current = await _loadItems(userId);
      final existingIds = current.map((e) => e.id).toSet();
      final merged = [
        ...current,
        ...legacyItems.where((e) => !existingIds.contains(e.id)),
      ];
      final trimmed = merged.length > _maxItems
          ? merged.sublist(0, _maxItems)
          : merged;
      await _saveItems(trimmed, userId);
      await prefs.remove(_storageKey);
    } catch (error) {
      debugPrint('알림 레거시 마이그레이션 실패: $error');
    }
  }
}
