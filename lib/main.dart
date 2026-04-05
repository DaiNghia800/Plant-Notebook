import 'package:flutter/material.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/routes/route.dart' as router;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      initialRoute: appViewRoute,
    );
  }
}
