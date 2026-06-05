import 'package:flutter/material.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/routes/view_export.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_notebook/data/services/firebase_messaging_service.dart';

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

  final List<String> _pageTitles = [
    "Trang chủ",
    "Vườn của tôi",
    "Quét cây",
    "Thư viện",
    "Cá nhân",
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: neutral,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: neutral.withOpacity(0.9),
        title: _isSearching && _currentIndex == 1
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm cây...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                ),
                onChanged: (value) {
                  Provider.of<MyGardenController>(context, listen: false)
                      .searchQuery = value;
                },
              )
            : Text(
                _pageTitles[_currentIndex],
                style: TextStyle(
                  color: primaryColor,
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
                icon: Icon(Icons.close, color: primaryColor),
              )
            : (_currentIndex != 0
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                    icon: Icon(Icons.arrow_back, color: primaryColor),
                  )
                : null),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications, color: primaryColor),
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
                icon: Icon(Icons.close, color: primaryColor),
              )
            else
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
                icon: Icon(Icons.search, color: primaryColor),
              ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: primaryColor),
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
                          color: currentSort == 'name' ? primaryColor : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sắp xếp theo tên (A-Z)',
                          style: TextStyle(
                            color: currentSort == 'name' ? primaryColor : null,
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
                              ? primaryColor
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sắp xếp theo nhu cầu tưới',
                          style: TextStyle(
                            color:
                                currentSort == 'waterNeed' ? primaryColor : null,
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
                          isGridView ? 'Chuyển sang Danh sách' : 'Chuyển sang Lưới',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Làm mới dữ liệu'),
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
                _isSearching = false;
                _searchController.clear();
              });
              Provider.of<MyGardenController>(context, listen: false)
                  .searchQuery = '';
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: "Trang chủ",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.spa),
                label: "Khu vườn",
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
                icon: Icon(Icons.library_books),
                label: "Thư viện",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Cá nhân",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
