import 'package:flutter/material.dart';
import 'package:plant_notebook/features/home/views/widget/watering_section/home_watering_section.dart';
import 'package:plant_notebook/features/home/views/widget/garden_health/home_garden_health.dart';
import 'package:plant_notebook/features/home/views/widget/hero_banner/home_hero_banner.dart';
import 'package:plant_notebook/features/home/views/widget/quick_actions/home_quick_actions.dart';
import 'package:plant_notebook/features/home/views/widget/discover_plant/home_discover_plant.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // Hiệu ứng cuộn mượt
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 20.0,
        ), // Căn lề tổng thể (nếu trước đó chưa có)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            HomeHeroBanner(),
            SizedBox(height: 28),
            HomeQuickActions(),
            SizedBox(height: 28),
            HomeWateringSection(),
            SizedBox(height: 28),
            HomeGardenHealth(),
            SizedBox(height: 28),
            HomeDiscoverPlant(),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
