import 'package:flutter/material.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/utils/constant.dart';
import 'package:plant_notebook/view/onboarding/onboarding_storage.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: 'Từ điển cây',
      description:
          'Tra cứu nhanh đặc tính, cách chăm sóc và mẹo nhận biết từng loài cây.',
      icon: Icons.menu_book_rounded,
      accentColor: Color(0xFF2E7D32),
      backgroundTint: Color(0xFFDFF3E3),
      badgeLabel: 'PLANT GUIDE',
      badgeIcon: Icons.auto_stories_outlined,
      footerLabel: 'Khám phá thế giới cây trồng',
    ),
    _OnboardingData(
      title: 'Nhắc lịch tưới',
      description:
          'Thiết lập lịch tưới thông minh để cây luôn được chăm sóc đúng lúc.',
      icon: Icons.water_drop_rounded,
      accentColor: Color(0xFF1E8C4A),
      backgroundTint: Color(0xFFD8F4DF),
      badgeLabel: 'SMART ALERT',
      badgeIcon: Icons.alarm_rounded,
      footerLabel: 'Không quên tưới cây',
    ),
    _OnboardingData(
      title: 'Nhận diện bệnh bằng AI',
      description: 'Chụp ảnh lá cây để phát hiện dấu hiệu bất thường sớm.',
      icon: Icons.document_scanner_outlined,
      accentColor: Color(0xFF166534),
      backgroundTint: Color(0xFFDCEFE0),
      badgeLabel: 'AI SCANNING',
      badgeIcon: Icons.camera_alt_rounded,
      footerLabel: 'Chẩn đoán cây bằng AI',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Đánh dấu đã xem onboarding và chuyển sang màn hình chính.
  Future<void> _finishOnboarding() async {
    await OnboardingStorage.setCompleted(true);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(homeViewRoute);
  }

  /// Nút chính: sang trang kế tiếp hoặc hoàn tất nếu đang ở trang cuối.
  Future<void> _handlePrimaryAction() async {
    if (_currentPage == _pages.length - 1) {
      await _finishOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  /// Bỏ qua onboarding và xem như đã hoàn tất.
  Future<void> _skipOnboarding() async {
    await _finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FCF7), Color(0xFFEAF7ED), Color(0xFFF7FBF8)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -80,
                left: -70,
                child: _BlurCircle(
                  size: 220,
                  color: primaryColor.withOpacity(0.08),
                ),
              ),
              Positioned(
                bottom: -100,
                right: -60,
                child: _BlurCircle(
                  size: 250,
                  color: secondary.withOpacity(0.12),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _skipOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Skip'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final _OnboardingData data = _pages[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(height: 4),
                              Expanded(
                                child: Center(
                                  child: _OnboardingIllustration(data: data),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Column(
                                children: [
                                  Text(
                                    data.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 31,
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                      color: Color(0xFF0E1510),
                                      letterSpacing: -0.7,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    data.description,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 19,
                                      height: 1.55,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black.withOpacity(0.62),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              _PageIndicator(
                                currentPage: _currentPage,
                                itemCount: _pages.length,
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _handlePrimaryAction,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 22,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(36),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        index == _pages.length - 1
                                            ? 'Bắt đầu ngay'
                                            : 'Tiếp tục',
                                        style: const TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      const Icon(Icons.arrow_forward_rounded),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                data.footerLabel,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black.withOpacity(0.36),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.backgroundTint,
    required this.badgeLabel,
    required this.badgeIcon,
    required this.footerLabel,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color backgroundTint;
  final String badgeLabel;
  final IconData badgeIcon;
  final String footerLabel;
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(42),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    data.backgroundTint.withOpacity(0.95),
                    Colors.white.withOpacity(0.88),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: data.accentColor.withOpacity(0.10),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 24,
                    left: 22,
                    child: _FloatingChip(
                      icon: data.badgeIcon,
                      label: data.badgeLabel,
                      backgroundColor: Colors.white.withOpacity(0.92),
                      foregroundColor: data.accentColor,
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: 22,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        data.icon,
                        color: data.accentColor.withOpacity(0.95),
                        size: 34,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StoryArtwork(data: data),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.90),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: data.accentColor.withOpacity(0.10),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Text(
                            data.badgeLabel,
                            style: TextStyle(
                              color: data.accentColor,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: -18,
              left: 0,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(data.icon, color: data.accentColor, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryArtwork extends StatelessWidget {
  const _StoryArtwork({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    switch (data.title) {
      case 'Từ điển cây':
        return _PlantLibraryArtwork(accentColor: data.accentColor);
      case 'Nhắc lịch tưới':
        return _WaterReminderArtwork(accentColor: data.accentColor);
      default:
        return _AiScanArtwork(accentColor: data.accentColor);
    }
  }
}

class _PlantLibraryArtwork extends StatelessWidget {
  const _PlantLibraryArtwork({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 12,
            bottom: 12,
            child: _MiniPlantPot(
              accentColor: accentColor,
              color: const Color(0xFFF6B07D),
              scale: 0.86,
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: _MiniPlantPot(
              accentColor: accentColor,
              color: const Color(0xFFF6E3C5),
              scale: 0.92,
            ),
          ),
          Positioned(
            left: 95,
            top: 10,
            child: _MiniPlantPot(
              accentColor: accentColor,
              color: const Color(0xFFEAE0C8),
              scale: 1.0,
            ),
          ),
          Positioned(
            right: 70,
            top: 34,
            child: _MiniPlantPot(
              accentColor: accentColor,
              color: const Color(0xFFF1A47E),
              scale: 0.96,
            ),
          ),
          Container(
            width: 178,
            height: 128,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.52),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: accentColor.withOpacity(0.9),
              size: 72,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterReminderArtwork extends StatelessWidget {
  const _WaterReminderArtwork({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.09),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(34),
            ),
          ),
          Positioned(
            left: 36,
            bottom: 20,
            child: _FloatingChip(
              icon: Icons.alarm_add_rounded,
              label: 'SMART ALERT',
              backgroundColor: const Color(0xFFD9FFD8),
              foregroundColor: accentColor,
            ),
          ),
          Positioned(
            right: 18,
            top: 24,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.water_drop_rounded,
                color: accentColor,
                size: 38,
              ),
            ),
          ),
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 8),
            ),
            child: Icon(Icons.spa_rounded, color: accentColor, size: 60),
          ),
        ],
      ),
    );
  }
}

class _AiScanArtwork extends StatelessWidget {
  const _AiScanArtwork({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white.withOpacity(0.82),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEEF5EE),
                          const Color(0xFFDCE9DD),
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.eco_rounded,
                          color: accentColor.withOpacity(0.45),
                          size: 92,
                        ),
                        Positioned(
                          bottom: 16,
                          child: _FloatingChip(
                            icon: Icons.auto_awesome_rounded,
                            label: 'AI SCANNING',
                            backgroundColor: Colors.white,
                            foregroundColor: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.center_focus_strong_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingChip extends StatelessWidget {
  const _FloatingChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foregroundColor, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPlantPot extends StatelessWidget {
  const _MiniPlantPot({
    required this.accentColor,
    required this.color,
    required this.scale,
  });

  final Color accentColor;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Column(
        children: [
          Icon(
            Icons.local_florist_rounded,
            color: accentColor.withOpacity(0.9),
            size: 30,
          ),
          const SizedBox(height: 2),
          Container(
            width: 42,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentPage, required this.itemCount});

  final int currentPage;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final bool selected = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: selected ? 34 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: selected ? primaryColor : const Color(0xFFC5D1C6),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
