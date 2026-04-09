import 'package:shared_preferences/shared_preferences.dart';

class MyGardenStorage {
  static const String savedIdsKey = 'my_garden_saved_plant_ids';

  /// Đọc danh sách id cây đã lưu từ SharedPreferences.
  Future<List<String>> readSavedPlantIds() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(savedIdsKey) ?? <String>[];
  }

  /// Ghi danh sách id cây xuống SharedPreferences.
  Future<void> writeSavedPlantIds(List<String> ids) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(savedIdsKey, ids);
  }
}
