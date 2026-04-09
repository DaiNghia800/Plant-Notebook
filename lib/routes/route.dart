import 'package:flutter/material.dart';
import 'package:plant_notebook/app/app.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/routes/view_export.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case appViewRoute:
      return MaterialPageRoute(builder: (context) => const App());
    case homeViewRoute:
      return MaterialPageRoute(builder: (context) => const HomeView());
    case myGardenViewRoute:
      return MaterialPageRoute(builder: (context) => const MyGardenView());
    case scannerViewRoute:
      return MaterialPageRoute(builder: (context) => const PlantScannerView());
    case libraryViewRoute:
      return MaterialPageRoute(builder: (context) => const LibraryView());
    case profileViewRoute:
      return MaterialPageRoute(builder: (context) => const ProfileView());
    default:
      return MaterialPageRoute(builder: (context) => const HomeView());
  }
}
