import 'package:flutter/material.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/routes/route.dart' as router;

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:plant_notebook/controller/plant_scanner_controller.dart';
import 'package:plant_notebook/controller/profile_controller.dart';
import 'package:plant_notebook/utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlantScannerController()),
        ChangeNotifierProvider(
          create: (_) => MyGardenController()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: profileController.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light().copyWith(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        hintColor: AppColors.textLight,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Colors.white,
          error: AppColors.danger,
          onSurface: AppColors.textMain,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: const Color(0xFF121212),
        hintColor: Colors.grey[400],
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Color(0xFF1E1E1E),
          error: AppColors.danger,
          onSurface: Colors.white,
        ),
      ),
      onGenerateRoute: router.generateRoute,
      initialRoute: appViewRoute,
    );
  }
}

