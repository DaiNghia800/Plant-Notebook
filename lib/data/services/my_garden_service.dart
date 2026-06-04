import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plant_notebook/data/network/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_notebook/data/models/category.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';
import 'package:plant_notebook/data/models/care_history.dart';

class MyGardenService {
  late final Dio _dio = DioClient.createDio();

  Future<List<GardenPlantProfile>> fetchPlantProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    final dynamic decoded = await _request(
      method: 'GET',
      path: '/my-garden/plants${userId != null ? '?userId=$userId' : ''}',
    );
    final List<dynamic> list = _extractList(decoded, fallbackKey: 'data');
    return list
        .whereType<Map<String, dynamic>>()
        .map(GardenPlantProfile.fromJson)
        .toList(growable: false);
  }

  Future<List<GardenCategory>> fetchPlantCategory() async {
    final dynamic decoded = await _request(
      method: 'GET',
      path: '/my-garden/category',
    );
    final List<dynamic> list = _extractList(decoded, fallbackKey: 'data');
    return list
        .whereType<Map<String, dynamic>>()
        .map(GardenCategory.fromJson)
        .toList(growable: false);
  }

  Future<GardenPlantProfile> createPlantProfile(
    GardenPlantProfile profile,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final String userId =
        prefs.getString('userId') ?? 'b4d41cb9-d751-4e2d-9c85-a8dc3f0063ec';
    final FormData formData = FormData.fromMap({
      if (profile.plantId.isNotEmpty) 'plantId': profile.plantId,
      'plantName': profile.name,
      'categoryId': profile.category.id,
      'status': _statusLabel(profile.status),
      'startedAt': profile.startDate.toIso8601String(),
      'wateringCycle': profile.reminderSetting.wateringCycleDays.toString(),
      'fertilizingCycle': profile.reminderSetting.fertilizingCycleDays
          .toString(),
      'isPushEnabled': profile.reminderSetting.pushNotificationEnabled
          .toString(),
      'userId': userId,
    });

    final bool hasLocalImage =
        profile.imageUrl.isNotEmpty && !profile.imageUrl.startsWith('http');
    if (hasLocalImage) {
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            profile.imageUrl,
            filename: profile.imageUrl.split(Platform.pathSeparator).last,
          ),
        ),
      );
    } else if (profile.imageUrl.isNotEmpty) {
      formData.fields.add(MapEntry('imageUrl', profile.imageUrl));
    }

    try {
      final Response<dynamic> response = await _dio.post(
        '/my-garden/plants',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final Map<String, dynamic> decoded =
          response.data as Map<String, dynamic>;
      final Map<String, dynamic> data = decoded['data'] as Map<String, dynamic>;
      return GardenPlantProfile.fromJson(data);
    } on DioException catch (error) {
      final int statusCode = error.response?.statusCode ?? -1;
      debugPrint("Lỗi $statusCode: ${error.response?.data}");
      throw Exception('api_error_$statusCode:$error');
    }
  }

  String _statusLabel(GardenPlantStatus status) {
    switch (status) {
      case GardenPlantStatus.thirsty:
        return 'Đang khát';
      case GardenPlantStatus.sick:
        return 'Đang bệnh';
      case GardenPlantStatus.healthy:
        return 'Khỏe mạnh';
    }
  }

  Future<GardenPlantProfile> updatePlantProfile(
    GardenPlantProfile profile,
  ) async {
    if (profile.id == null || profile.id!.isEmpty) {
      throw Exception('missing_garden_plant_id');
    }
    final bool hasLocalImage =
        profile.imageUrl.isNotEmpty && !profile.imageUrl.startsWith('http');
    debugPrint("Profile id: ${profile.plantId}");

    if (hasLocalImage) {
      final FormData formData = FormData.fromMap({
        'plantId': profile.plantId,
        'plantName': profile.name,
        'categoryId': profile.category.id,
        'status': _statusLabel(profile.status),
        'startedAt': profile.startDate.toIso8601String(),
        'wateringCycleDays': profile.reminderSetting.wateringCycleDays
            .toString(),
        'fertilizingCycleDays': profile.reminderSetting.fertilizingCycleDays
            .toString(),
        'isPushEnabled': profile.reminderSetting.pushNotificationEnabled
            .toString(),
        'image': await MultipartFile.fromFile(
          profile.imageUrl,
          filename: profile.imageUrl.split(Platform.pathSeparator).last,
        ),
      });
      final Response<dynamic> response = await _dio.put(
        '/my-garden/plants/${profile.id}',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final Map<String, dynamic> decoded =
          response.data as Map<String, dynamic>;
      final Map<String, dynamic> data = decoded['data'] as Map<String, dynamic>;
      return GardenPlantProfile.fromJson(data);
    }

    final Map<String, dynamic> body = <String, dynamic>{
      'plantId': profile.plantId,
      'plantName': profile.name,
      'categoryId': profile.category.id,
      'status': _statusLabel(profile.status),
      'startedAt': profile.startDate.toIso8601String(),
      'wateringCycleDays': profile.reminderSetting.wateringCycleDays,
      'fertilizingCycleDays': profile.reminderSetting.fertilizingCycleDays,
      'isPushEnabled': profile.reminderSetting.pushNotificationEnabled,
    };
    final dynamic decoded = await _request(
      method: 'PUT',
      path: '/my-garden/plants/${profile.id}',
      body: body,
    );
    if (decoded is Map<String, dynamic> &&
        decoded['data'] is Map<String, dynamic>) {
      return GardenPlantProfile.fromJson(
        decoded['data'] as Map<String, dynamic>,
      );
    }
    return profile;
  }

  Future<void> deletePlantProfile(String gardenPlantId) async {
    await _request(method: 'DELETE', path: '/my-garden/plants/$gardenPlantId');
  }

  Future<List<PlantCareHistory>> fetchPlantCareHistory(
    String gardenPlantId,
  ) async {
    final dynamic decoded = await _request(
      method: 'GET',
      path: '/my-garden/plants/$gardenPlantId/care-history',
    );
    final List<dynamic> list = _extractList(decoded, fallbackKey: 'data');
    return list
        .whereType<Map<String, dynamic>>()
        .map(PlantCareHistory.fromJson)
        .toList(growable: false);
  }

  Future<PlantCareHistory> createCareHistory(
    String gardenPlantId,
    CareActionType actionType,
    String? notes,
  ) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'gardenPlantId': gardenPlantId,
      'type': actionType.name,
      'actionDate': DateTime.now().toIso8601String(),
      'notes': notes,
    };

    final dynamic decoded = await _request(
      method: 'POST',
      path: '/my-garden/care-history',
      body: body,
    );

    if (decoded is Map<String, dynamic> &&
        decoded['data'] is Map<String, dynamic>) {
      return PlantCareHistory.fromJson(decoded['data'] as Map<String, dynamic>);
    }

    throw Exception('Failed to create care history');
  }

  Future<dynamic> _request({
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

  List<dynamic> _extractList(dynamic decoded, {required String fallbackKey}) {
    if (decoded is List<dynamic>) {
      return decoded;
    }
    if (decoded is Map<String, dynamic>) {
      final dynamic nested = decoded[fallbackKey];
      if (nested is List<dynamic>) {
        return nested;
      }
    }
    return const <dynamic>[];
  }

  Map<String, dynamic> _extractMap(dynamic decoded, {String? fallbackKey}) {
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
}
