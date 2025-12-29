import 'dart:convert';

import 'package:boulderside_flutter/src/core/notifications/models/notice_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticeNotificationStore extends StateNotifier<List<NoticeNotification>> {
  NoticeNotificationStore() : super(const []);

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

  Future<void> add(NoticeNotification item) async {
    state = await persistNotification(item);
  }

  Future<void> clear() async {
    final userId = await _getActiveUserId();
    if (userId != null && userId.isNotEmpty) {
      await _saveItems(const [], userId);
      await _clearActiveUserId();
    }
    state = const [];
  }

  static Future<List<NoticeNotification>> persistNotification(
    NoticeNotification item,
    {String? userId}
  ) async {
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

  static Future<void> _clearActiveUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeUserIdKey);
    } catch (error) {
      debugPrint('알림 사용자 키 삭제 실패: $error');
    }
  }

  static List<NoticeNotification> _merge(
    NoticeNotification item,
    List<NoticeNotification> existing,
  ) {
    final filtered = existing.where((e) => e.id != item.id).toList();
    final merged = [item, ...filtered];
    return merged.length > _maxItems ? merged.sublist(0, _maxItems) : merged;
  }

  static Future<List<NoticeNotification>> _loadItems(String userId) async {
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
          .map(NoticeNotification.fromJson)
          .toList();
    } catch (error) {
      debugPrint('알림 목록 로드 실패: $error');
      return const [];
    }
  }

  static Future<void> _saveItems(
    List<NoticeNotification> items,
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

  static String _storageKeyForUser(String userId) =>
      '${_storageKey}_$userId';

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
          .map(NoticeNotification.fromJson)
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
      final trimmed =
          merged.length > _maxItems ? merged.sublist(0, _maxItems) : merged;
      await _saveItems(trimmed, userId);
      await prefs.remove(_storageKey);
    } catch (error) {
      debugPrint('알림 레거시 마이그레이션 실패: $error');
    }
  }
}
