import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:plant_notebook/data/models/garden_plant.dart';
import 'package:plant_notebook/data/network/dio_client.dart';
import 'package:plant_notebook/data/services/my_garden_service.dart';
import 'package:plant_notebook/screens/my_garden/plant_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/main.dart' show navigatorKey;
import 'package:plant_notebook/utils/url_resolver.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static String? _currentToken;
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'plant_notebook_reminders',
    'Plant Notebook Reminders',
    description: 'Reminder notifications for plant care',
    importance: Importance.high,
  );

  static String _baseUrl() {
    final String? url = dotenv.env['API_BASE_URL'];
    final String resolved = (url == null || url.isEmpty)
        ? 'http://localhost:5000'
        : url;
    return resolved.replaceFirst(RegExp(r'/+$'), '');
  }

  static final Dio _dio = DioClient.createDio();

  static Future<dynamic> _request({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    try {
      final Response<dynamic> response = await _dio.request<dynamic>(
        path,
        data: body,
        options: Options(method: method),
      );

      if (response.data == null || response.data.toString().trim().isEmpty) {
        return <String, dynamic>{};
      }
      return response.data;
    } on DioException catch (error) {
      final int statusCode = error.response?.statusCode ?? -1;
      throw Exception('api_error_$statusCode:$error');
    }
  }

  static Map<String, dynamic> _extractMap(
    dynamic decoded, {
    String? fallbackKey,
  }) {
    // Trường hợp 1: API trả trực tiếp object
    if (decoded is Map<String, dynamic>) {
      // Nếu có key data thì ưu tiên lấy trong đó
      if (fallbackKey != null &&
          decoded.containsKey(fallbackKey) &&
          decoded[fallbackKey] is Map<String, dynamic>) {
        return decoded[fallbackKey] as Map<String, dynamic>;
      }

      return decoded;
    }

    // Trường hợp 2: API trả list nhưng bạn cần lấy phần tử đầu
    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first;
      if (first is Map<String, dynamic>) {
        return first;
      }
    }

    // Trường hợp lỗi
    throw Exception('Cannot extract Map from response: $decoded');
  }

  static Future<GardenPlantProfile> fetchPlantProfileById(String id) async {
    final dynamic decoded = await _request(
      method: 'GET',
      path: '/my-garden/plants/$id',
    );
    final Map<String, dynamic> data = _extractMap(decoded, fallbackKey: 'data');

    return GardenPlantProfile.fromJson(data);
  }

  static Future<void> initialize() async {
    await _initializeLocalNotifications();

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    try {
      _currentToken = await _firebaseMessaging.getToken();
      print('FCM Token: $_currentToken');
    } catch (e) {
      print('Failed to get FCM token: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final bool isNotificationOn = prefs.getBool('is_notification_on') ?? true;
    final String? userId = prefs.getString('userId');
    if (isNotificationOn && userId != null && _currentToken != null) {
      await _sendTokenToServer(userId, _currentToken!);
    }

    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      _currentToken = newToken;
      print('FCM Token refreshed: $newToken');
      _registerTokenIfLoggedIn(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
      _showForegroundNotification(message);
    });

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        _navigateToPlant(message);
      }
    });

    // Handle notification tap when app is in foreground
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      _navigateToPlant(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> registerToken(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isNotificationOn = prefs.getBool('is_notification_on') ?? true;
      if (!isNotificationOn) {
        await removeFcmTokenFromServer(userId);
        return;
      }
      _currentToken ??= await _firebaseMessaging.getToken();
      if (_currentToken == null) return;
      await _sendTokenToServer(userId, _currentToken!);
    } catch (e) {
      print('Failed to register FCM token: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      _currentToken ??= await _firebaseMessaging.getToken();
    } catch (e) {
      print('Failed to get FCM token: $e');
    }
    return _currentToken;
  }

  static Future<void> _registerTokenIfLoggedIn(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      if (userId != null) {
        await _sendTokenToServer(userId, token);
      }
    } catch (e) {
      print('Error registering refreshed token: $e');
    }
  }

  static Future<void> _sendTokenToServer(String userId, String token) async {
    try {
      final String resolvedBase = await UrlResolver.resolve(_baseUrl());
      final response = await http.post(
        Uri.parse('$resolvedBase/user/update-fcm-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        print('FCM token sent to server successfully');
      } else {
        print(
          'Failed to send FCM token: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error sending FCM token: $e');
    }
  }

  static Future<void> removeFcmTokenFromServer(String userId) async {
    try {
      final String resolvedBase = await UrlResolver.resolve(_baseUrl());
      final response = await http.post(
        Uri.parse('$resolvedBase/user/update-fcm-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'fcmToken': null}),
      );

      if (response.statusCode == 200) {
        print('FCM token removed from server successfully');
      } else {
        print(
          'Failed to remove FCM token: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error removing FCM token: $e');
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle local notification tap
        final payload = response.payload;
        debugPrint("payload: ${payload}");

        if (payload != null) {
          _handleNotificationPayload(payload);
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'plant_notebook_reminders',
          'Plant Notebook Reminders',
          channelDescription: 'Reminder notifications for plant care',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title ?? 'Plant Notebook',
      body: notification.body ?? 'Ban co thong bao moi',
      notificationDetails: details,
      payload: message.data['gardenPlantId'] ?? '',
    );
  }

  static void _navigateToPlant(RemoteMessage message) {
    final String? gardenPlantId = message.data['gardenPlantId'];
    if (gardenPlantId != null && gardenPlantId.isNotEmpty) {
      _handlePlantNavigation(gardenPlantId);
    }
  }

  static void _handleNotificationPayload(String payload) {
    if (payload.isNotEmpty) {
      _handlePlantNavigation(payload);
    }
  }

  static Future<void> _handlePlantNavigation(String gardenPlantId) async {
    try {
      // Get the plant profile from controller or fetch it
      // For now, navigate to MyGarden and let user find it
      // In a production app, you would fetch the plant details by ID
      final profile = await fetchPlantProfileById(gardenPlantId);
      debugPrint("profile: ${profile.toJson()}");
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => PlantDetailScreen(profile: profile)),
      );
    } catch (e) {
      print('Error handling plant navigation: $e');
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
