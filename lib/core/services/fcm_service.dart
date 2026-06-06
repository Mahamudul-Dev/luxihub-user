import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/chat/data/models/conversation_model.dart';

/// Top-level function — required by FCM for background message handling.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.notification?.title}');
}

class FcmService {
  FcmService._();
  static final instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  final _client = Supabase.instance.client;

  GoRouter? _router;

  /// Call once after the router is created (from main.dart).
  void setRouter(GoRouter router) => _router = router;

  /// Call once after the user authenticates.
  Future<void> initialize(String userId) async {
    await _requestPermission();
    await _saveCurrentToken(userId);
    _onTokenRefresh(userId);
    _onForegroundMessage();
    await _handleInitialMessage();
    _onMessageOpenedApp();
  }

  /// Remove token on logout so the user stops receiving push after sign-out.
  Future<void> removeToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await _client
          .from('device_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('token', token);
      await _messaging.deleteToken();
      debugPrint('[FCM] Token removed for user $userId');
    } catch (e) {
      debugPrint('[FCM] removeToken error: $e');
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
  }

  Future<void> _saveCurrentToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _upsertToken(userId, token);
    } catch (e) {
      debugPrint('[FCM] _saveCurrentToken error: $e');
    }
  }

  void _onTokenRefresh(String userId) {
    _messaging.onTokenRefresh.listen((token) async {
      debugPrint('[FCM] Token refreshed');
      await _upsertToken(userId, token);
    });
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      // Chat messages: Realtime subscription already updates the UI.
      // General notifications: Realtime handles them too.
      // Nothing extra needed in foreground.
      debugPrint(
          '[FCM] Foreground message received: ${message.notification?.title} '
          '(type=${message.data["type"]}) — Realtime handles the UI update.');
    });
  }

  /// Handles taps when the app was completely terminated.
  Future<void> _handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      debugPrint('[FCM] App opened from terminated state via notification');
      // Delay to let the router finish initialising
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await _routeFromMessage(message);
    }
  }

  /// Handles taps when the app was in the background.
  void _onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      debugPrint('[FCM] App resumed from background via notification');
      await _routeFromMessage(message);
    });
  }

  Future<void> _routeFromMessage(RemoteMessage message) async {
    final type = message.data['type'] as String?;
    if (type == 'chat') {
      await _navigateToChat(message.data['conversationId'] as String?);
    }
    // Other types (general, job_update, payment, system) → open notifications page
    else if (type != null) {
      _router?.pushNamed('Notifications');
    }
  }

  Future<void> _navigateToChat(String? conversationId) async {
    if (conversationId == null || _router == null) return;
    try {
      final row = await _client
          .from('conversations')
          .select('*, provider:provider_id(name, avatar_path)')
          .eq('id', conversationId)
          .single();

      final conversation = ConversationModel.fromJson(row);
      _router!.pushNamed(
        'Chat',
        pathParameters: {'conversationId': conversationId},
        extra: conversation,
      );
      debugPrint('[FCM] Navigated to chat $conversationId');
    } catch (e) {
      debugPrint('[FCM] _navigateToChat error: $e');
    }
  }

  Future<void> _upsertToken(String userId, String token) async {
    try {
      await _client.from('device_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,token',
      );
      debugPrint('[FCM] Token saved for user $userId');
    } catch (e) {
      debugPrint('[FCM] _upsertToken error: $e');
    }
  }
}
