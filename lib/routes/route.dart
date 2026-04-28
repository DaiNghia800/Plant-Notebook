import 'package:flutter/material.dart';
import 'package:plant_notebook/app/app.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/routes/view_export.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case appViewRoute:
      return MaterialPageRoute(builder: (context) => const App());
    case homeViewRoute:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
    case myGardenViewRoute:
      return MaterialPageRoute(builder: (context) => const MyGardenScreen());
    case scannerViewRoute:
      return MaterialPageRoute(
        builder: (context) => const PlantScannerScreen(),
      );
    case libraryViewRoute:
      return MaterialPageRoute(builder: (context) => const LibraryScreen());
    case profileViewRoute:
      return MaterialPageRoute(builder: (context) => const ProfileScreen());
    default:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
  }
}
