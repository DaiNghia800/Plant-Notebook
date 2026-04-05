import 'package:flutter/material.dart';
import 'package:plant_notebook/view/home/widget/Home_watering_section.dart';
import 'package:plant_notebook/view/home/widget/home_garden_health.dart';
import 'package:plant_notebook/view/home/widget/home_hero_banner.dart';
import 'package:plant_notebook/view/home/widget/home_quick_actions.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        HomeHeroBanner(),
        SizedBox(height: 28),
        HomeQuickActions(),
        SizedBox(height: 28),
        HomeWateringSection(),
        SizedBox(height: 28),
        HomeGardenHealth(),
        SizedBox(height: 24),
      ],
    );
  }
}
