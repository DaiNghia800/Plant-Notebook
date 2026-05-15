import 'package:flutter/material.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/routes/route.dart' as router;

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:plant_notebook/controller/plant_scanner_controller.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      navigatorKey: navigatorKey,
      onGenerateRoute: router.generateRoute,
      initialRoute: initialRoute,
    );
  }
}
