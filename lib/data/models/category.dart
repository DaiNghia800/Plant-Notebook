enum Category { all, indoor, balcony, outdoor }

class GardenCategory {
  const GardenCategory({required this.id, required this.name});

  final String id;
  final Category name;

  factory GardenCategory.fromJson(Map<String, dynamic> json) {
    return GardenCategory(
      id: json['id']?.toString() ?? '',
      name: _parseCategory(json['name']?.toString()),
    );
  }

  static Category _parseCategory(String? name) {
    switch (name) {
      case 'Trong nhà':
        return Category.indoor;
      case 'Ban công':
        return Category.balcony;
      case 'Ngoài trời':
        return Category.outdoor;
      default:
        return Category.all;
    }
  }

  static String categoryToText(Category category) {
    switch (category) {
      case Category.indoor:
        return 'Trong nhà';
      case Category.balcony:
        return 'Ban công';
      case Category.outdoor:
        return 'Ngoài trời';
      default:
        return 'Tất cả';
    }
  }
}
