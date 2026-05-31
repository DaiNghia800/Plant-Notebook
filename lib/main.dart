import 'package:flutter/material.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/routes/route.dart' as router;

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:plant_notebook/controller/plant_scanner_controller.dart';
import 'package:plant_notebook/controller/store_controller.dart';
import 'package:plant_notebook/controller/profile_controller.dart';
import 'package:plant_notebook/utils/app_colors.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:plant_notebook/data/services/firebase_messaging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global navigation key for notification handling
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Firebase Messaging
  await FirebaseMessagingService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.containsKey('userId');
  final String initialRoute = isLoggedIn ? appViewRoute : loginViewRoute;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlantScannerController()),
        ChangeNotifierProvider(
          create: (_) => MyGardenController()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => StoreController()..fetchStores(),
        ),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialRoute = appViewRoute});

  final String initialRoute;

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
      initialRoute: splashViewRoute,
    );
  }
}
