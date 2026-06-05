import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/screens/home/home_screen.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:plant_notebook/controller/library_plant_controller.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

void main() {
  testWidgets('HomeScreen renders without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MyGardenController()),
          ChangeNotifierProvider(create: (_) => LibraryPlantController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: HomeScreen(),
          ),
        ),
      ),
    );
    
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
