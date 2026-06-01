import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_notebook/data/models/my_garden_item.dart';

class MyGardenStorage {
  static const String savedPlantsKey = 'my_garden_saved_plants_json';

  /// Đọc danh sách cây đã lưu từ SharedPreferences.
  Future<List<MyGardenItem>> readSavedPlants() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? jsonString = preferences.getString(savedPlantsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return <MyGardenItem>[];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => MyGardenItem.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Bỏ qua lỗi parse và trả về rỗng nếu dữ liệu cũ bị hỏng hoặc định dạng sai.
      return <MyGardenItem>[];
    }
  }

  /// Ghi danh sách cây xuống SharedPreferences.
  Future<void> writeSavedPlants(List<MyGardenItem> plants) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> mapList = plants
        .map((e) => e.toMap())
        .toList();
    final String jsonString = jsonEncode(mapList);
    await preferences.setString(savedPlantsKey, jsonString);
  }
}
