import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

class MyGardenHeader extends StatelessWidget {
  const MyGardenHeader({super.key, required this.totalPlants});

  final int totalPlants;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<ProfileController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.tr('my_garden'),
          style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 6),
        Text(
          '${lang.tr('garden_subtitle_prefix')} $totalPlants ${lang.tr('garden_subtitle_suffix')}',
          style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}
