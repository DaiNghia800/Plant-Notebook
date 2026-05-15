import 'package:flutter/material.dart';
import 'package:plant_notebook/screens/home/widget/watering_section/home_watering_section.dart';
import 'package:plant_notebook/screens/home/widget/garden_health/home_garden_health.dart';
import 'package:plant_notebook/screens/home/widget/hero_banner/home_hero_banner.dart';
import 'package:plant_notebook/screens/home/widget/quick_actions/home_quick_actions.dart';
import 'package:plant_notebook/screens/home/widget/discover_plant/home_discover_plant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // Hiệu ứng cuộn mượt
      child: Padding(
        padding: EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 60),
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
