import 'package:flutter/material.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/routes/view_export.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_notebook/data/services/firebase_messaging_service.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    _registerFcmToken();
  }

  Future<void> _registerFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    if (userId != null) {
      await FirebaseMessagingService.registerToken(userId);
    }
  }

  final List _pages = [
  const HomeScreen(),
  const MyGardenScreen(),
  const PlantScannerScreen(),
  const LibraryScreen(),
  ProfileScreen(), 
];

  List<String> _getPageTitles(ProfileController lang) => [
    lang.tr('home'),
    lang.tr('garden'),
    lang.tr('scan'),
    lang.tr('library'),
    lang.tr('profile'),
  ];

  int _currentIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<ProfileController>();
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final fgColor = theme.primaryColor;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: bgColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: bgColor.withOpacity(0.9),
        title: _isSearching && _currentIndex == 1
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: lang.tr('search_plant'),
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                style: TextStyle(
                  color: fgColor,
                  fontSize: 18,
                ),
                onChanged: (value) {
                  Provider.of<MyGardenController>(context, listen: false)
                      .searchQuery = value;
                },
              )
            : Text(
                _getPageTitles(lang)[_currentIndex],
                style: TextStyle(
                  color: fgColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
        leading: _isSearching && _currentIndex == 1
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                  Provider.of<MyGardenController>(context, listen: false)
                      .searchQuery = '';
                },
                icon: Icon(Icons.close, color: fgColor),
              )
            : (_currentIndex != 0
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                    icon: Icon(Icons.arrow_back, color: fgColor),
                  )
                : null),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications, color: fgColor),
            ),
          if (_currentIndex == 1) ...[
            if (_isSearching)
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                  Provider.of<MyGardenController>(context, listen: false)
                      .searchQuery = '';
                },
                icon: Icon(Icons.close, color: fgColor),
              )
            else
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
                icon: Icon(Icons.search, color: fgColor),
              ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: fgColor),
              onSelected: (value) async {
                final myGardenController =
                    Provider.of<MyGardenController>(context, listen: false);
                if (value == 'sort_name') {
                  myGardenController.sortBy = 'name';
                } else if (value == 'sort_water') {
                  myGardenController.sortBy = 'waterNeed';
                } else if (value == 'toggle_view') {
                  myGardenController.isGridView = !myGardenController.isGridView;
                } else if (value == 'refresh') {
                  await myGardenController.initialize();
                }
              },
              itemBuilder: (BuildContext context) {
                final myGardenController =
                    Provider.of<MyGardenController>(context, listen: false);
                final currentSort = myGardenController.sortBy;
                final isGridView = myGardenController.isGridView;
                return [
                  PopupMenuItem<String>(
                    value: 'sort_name',
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort_by_alpha,
                          color: currentSort == 'name' ? fgColor : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lang.tr('sort_by_name'),
                          style: TextStyle(
                            color: currentSort == 'name' ? fgColor : null,
                            fontWeight: currentSort == 'name' ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'sort_water',
                    child: Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                            color: currentSort == 'waterNeed'
                                ? fgColor
                                : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lang.tr('sort_by_water'),
                          style: TextStyle(
                            color:
                                currentSort == 'waterNeed' ? fgColor : null,
                            fontWeight: currentSort == 'waterNeed'
                                ? FontWeight.bold
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'toggle_view',
                    child: Row(
                      children: [
                        Icon(
                          isGridView ? Icons.view_list : Icons.grid_view,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isGridView ? lang.tr('switch_to_list') : lang.tr('switch_to_grid'),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'refresh',
                    child: Row(
                      children: [
                        const Icon(Icons.refresh, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(lang.tr('refresh_data')),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
          if (_currentIndex == 3)
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.bookmark, color: fgColor),
            ),
          if (_currentIndex == 4)
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert, color: fgColor),
            ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
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
            backgroundColor: bgColor,
            currentIndex: _currentIndex,
            showUnselectedLabels: true,
            unselectedItemColor: const Color.fromARGB(255, 123, 123, 123),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w800,
              color: fgColor,
            ),
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800),
            selectedItemColor: fgColor,
            onTap: (value) {
              setState(() {
                _currentIndex = value;
                _isSearching = false;
                _searchController.clear();
              });
              Provider.of<MyGardenController>(context, listen: false)
                  .searchQuery = '';
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_filled),
                label: lang.tr('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.spa),
                label: lang.tr('garden'),
              ),
              BottomNavigationBarItem(
                icon: Container(
                  width: 70,
                  height: 70,
                  margin: EdgeInsets.only(top: 0),
                  decoration: BoxDecoration(
                    color: fgColor,
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: bgColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 3), // shadow rơi xuống dưới
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
                icon: const Icon(Icons.library_books),
                label: lang.tr('library'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: lang.tr('profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
