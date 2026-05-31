import 'package:flutter/material.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:plant_notebook/data/services/app_preferences.dart';
import 'package:plant_notebook/routes/route_constant.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Khám phá thế giới\ncây trồng',
      'description': 'Tra cứu hàng trăm loại cây và\ncách chăm sóc dễ dàng',
      'image': 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?auto=format&fit=crop&q=80&w=800',
      'icon': Icons.eco_rounded,
    },
    {
      'title': 'Không quên tưới cây',
      'description': 'Nhận nhắc nhở thông minh để cây luôn\nkhỏe mạnh',
      'image': 'https://images.unsplash.com/photo-1592150621744-aca64f48394a?auto=format&fit=crop&q=80&w=800',
      'icon': Icons.water_drop_rounded,
    },
  ];

  Future<void> _completeOnboarding() async {
    await AppPreferences.setHasSeenOnboarding(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(loginViewRoute);
  }

  void _nextPage() {
    if (_currentPage == _onboardingData.length - 1) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F6),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Bỏ qua',
                    style: TextStyle(
                      color: Color(0xFF104A1F),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          // Image wrapper
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 260,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD6E4DB),
                                  borderRadius: BorderRadius.circular(40),
                                  image: DecorationImage(
                                    image: NetworkImage(data['image']),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: -24,
                                left: -20,
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x14000000),
                                        blurRadius: 20,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      data['icon'],
                                      size: 30,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 60),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data['title'].split('\n')[0],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111C14),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data['title'].split('\n').length > 1 ? data['title'].split('\n')[1] : '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111C14),
                                ),
                              ),
                              if (index == 0) const Text(' 🌿', style: TextStyle(fontSize: 28)),
                              if (index == 1) const Text(' 💧', style: TextStyle(fontSize: 28)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data['description'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Color(0xFF4B6255),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, bottom: 60),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? primaryColor
                              : const Color(0xFFC3D6CA),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton(
                      onPressed: _nextPage,
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Tiếp tục',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 22),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
