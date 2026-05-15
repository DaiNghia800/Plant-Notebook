import 'package:flutter/material.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:plant_notebook/data/models/category.dart';

class MyGardenFilterChips extends StatelessWidget {
  const MyGardenFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final Category selectedCategory;
  final ValueChanged<Category> onCategoryChanged;

  static const List<(Category, String)> _filters = <(Category, String)>[
    (Category.all, 'Tất cả'),
    (Category.indoor, 'Trong nhà'),
    (Category.balcony, 'Ban công'),
    (Category.outdoor, 'Ngoài trời'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bool active = selectedCategory == _filters[index].$1;
          return GestureDetector(
            onTap: () => onCategoryChanged(_filters[index].$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: active ? primaryColor : const Color(0xFFE1E6E2),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                _filters[index].$2,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF2F4835),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
