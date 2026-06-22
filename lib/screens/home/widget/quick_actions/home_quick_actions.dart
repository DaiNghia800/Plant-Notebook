import 'package:flutter/material.dart';
import 'package:plant_notebook/screens/home/widget/quick_actions/quick_action_card.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:plant_notebook/screens/my_garden/widget/my_garden/my_garden_plant_form_sheet.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<ProfileController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.tr('quick_actions'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.document_scanner_outlined,
                iconColor: const Color(0xFF2E7D32),
                iconBgColor: const Color(0xFFE8F5E9),
                title: 'Scan AI',
                subtitle: lang.tr('scan_ai_desc'),
                onTap: () {
                  Navigator.of(context).pushNamed(scannerViewRoute);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                icon: Icons.add_circle,
                iconColor: const Color(0xFF2E7D32),
                iconBgColor: const Color(0xFFE8F5E9),
                title: lang.tr('add_plant'),
                subtitle: lang.tr('add_plant_desc'),
                onTap: () {
                  final controller = context.read<MyGardenController>();
                  final category = controller.plantCategory;
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    builder: (_) {
                      return MyGardenPlantFormSheet(
                        initialValue: null,
                        plantOptions: category,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.map_outlined,
                iconColor: const Color(0xFF1976D2),
                iconBgColor: const Color(0xFFE3F2FD),
                title: lang.tr('store_nursery'),
                subtitle: lang.tr('store_desc'),
                onTap: () {
                  Navigator.of(context).pushNamed(storeMapRoute);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                icon: Icons.people_outline_rounded,
                iconColor: const Color(0xFFE65100),
                iconBgColor: const Color(0xFFFBE9E7),
                title: lang.tr('community'),
                subtitle: lang.tr('community_desc'),
                onTap: () {
                  Navigator.of(context).pushNamed(communityViewRoute);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
