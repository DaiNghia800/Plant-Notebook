import 'package:flutter/material.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/routes/view_export.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final List _pages = [
  const HomeScreen(),
  const MyGardenScreen(),
  const PlantScannerScreen(),
  const LibraryScreen(),
  ProfileScreen(), 
];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: neutral,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: neutral.withOpacity(0.9),
        title: Text(
          "Sổ tay cây trồng",
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: _currentIndex != 0
            ? IconButton(
                onPressed: () {},
                icon: Icon(Icons.arrow_back, color: primaryColor),
              )
            : null,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications, color: primaryColor),
            ),
          if (_currentIndex == 1) ...[
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search, color: primaryColor),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert, color: primaryColor),
            ),
          ],
          if (_currentIndex == 3)
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.bookmark, color: primaryColor),
            ),
          if (_currentIndex == 4)
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert, color: primaryColor),
            ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: neutral,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -1),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            backgroundColor: neutral,
            currentIndex: _currentIndex,
            showUnselectedLabels: true,
            unselectedItemColor: const Color.fromARGB(255, 123, 123, 123),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800),
            selectedItemColor: primaryColor,
            onTap: (value) {
              setState(() {
                _currentIndex = value;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: "HOME",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.spa),
                label: "MY GARDEN",
              ),
              BottomNavigationBarItem(
                icon: Container(
                  width: 70,
                  height: 70,
                  margin: EdgeInsets.only(top: 0),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: neutral, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 3), // shadow rÆ¡i xuá»‘ng dÆ°á»›i
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, scannerViewRoute);
                    },
                    icon: Icon(
                      Icons.document_scanner_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books),
                label: "LIBRARY",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "PROFILE",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
