import 'package:flutter/material.dart';
import 'package:plant_notebook/app/app.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/routes/view_export.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case splashViewRoute:
      return MaterialPageRoute(builder: (context) => const SplashScreen());
    case onboardingViewRoute:
      return MaterialPageRoute(builder: (context) => const OnboardingScreen());
    case loginViewRoute:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case registerViewRoute:
      return MaterialPageRoute(builder: (context) => const RegisterScreen());
    case appViewRoute:
      return MaterialPageRoute(builder: (context) => const App());
    case homeViewRoute:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
    case myGardenViewRoute:
      return MaterialPageRoute(builder: (context) => const MyGardenScreen());
    case plantDetailViewRoute:
      final profile = settings.arguments;
      if (profile is GardenPlantProfile) {
        return MaterialPageRoute(
          builder: (context) => PlantDetailScreen(profile: profile),
        );
      }
      return MaterialPageRoute(builder: (context) => const MyGardenScreen());
    case scannerViewRoute:
      return MaterialPageRoute(
        builder: (context) => const PlantScannerScreen(),
      );
    case libraryViewRoute:
      return MaterialPageRoute(builder: (context) => const LibraryScreen());
    case profileViewRoute:
      return MaterialPageRoute(builder: (context) => const ProfileScreen());
    case storeMapRoute:
      return MaterialPageRoute(builder: (context) => const StoreMapScreen());
    case storeDetailRoute:
      final String storeId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => StoreDetailScreen(storeId: storeId),
      );
      return MaterialPageRoute(builder: (context) => ProfileScreen());
    case communityPostDetailRoute:
      return MaterialPageRoute(builder: (context) => PostDetailScreen());
    default:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
  }
}
