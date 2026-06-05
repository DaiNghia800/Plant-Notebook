import 'package:flutter/material.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:plant_notebook/data/models/category.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

class MyGardenFilterChips extends StatelessWidget {
  const MyGardenFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final Category selectedCategory;
  final ValueChanged<Category> onCategoryChanged;

  static const List<Category> _filters = <Category>[
    Category.all,
    Category.indoor,
    Category.balcony,
    Category.outdoor,
  ];

  String _getCategoryName(BuildContext context, Category category) {
    final lang = context.read<ProfileController>();
    switch (category) {
      case Category.all: return lang.tr('category_all');
      case Category.indoor: return lang.tr('category_indoor');
      case Category.balcony: return lang.tr('category_balcony');
      case Category.outdoor: return lang.tr('category_outdoor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bool active = selectedCategory == _filters[index];
          return GestureDetector(
            onTap: () => onCategoryChanged(_filters[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: active ? primaryColor : const Color(0xFFE1E6E2),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                _getCategoryName(context, _filters[index]),
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
