import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plant_notebook/data/models/library_plant_item.dart';
import 'package:plant_notebook/data/models/my_garden_item.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:provider/provider.dart';

class PlantDetailScreen extends StatefulWidget {
  const PlantDetailScreen({super.key, required this.plant});

  final LibraryPlantItem plant;

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _monthController.dispose();
    _imageController.dispose();
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyGardenController>(
      builder: (context, gardenController, _) {
        final gardenPlantList = gardenController.savedPlants
            .where((p) => p.libraryPlantId == widget.plant.id)
            .toList();
        final MyGardenItem? gardenPlant =
            gardenPlantList.isNotEmpty ? gardenPlantList.first : null;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: const Color(0xFF0D1F10),
            body: Stack(
              children: [
                _buildHeroSection(),
                _buildScrollableContent(context, gardenController, gardenPlant),
                _buildTopBar(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.52,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.plant.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A3A1E), Color(0xFF0D1F10)],
                  ),
                ),
                child: const Icon(Icons.local_florist, size: 100, color: Colors.white24),
              );
            },
          ),
          // Multi-layer gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4, 0.75, 1.0],
                colors: [
                  Color(0x60000000),
                  Colors.transparent,
                  Color(0x80000000),
                  Color(0xFF0D1F10),
                ],
              ),
            ),
          ),
          // Vignette on sides
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0x30000000), Colors.transparent, Color(0x30000000)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _GlassButton(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
            _GlassButton(
              onTap: () {},
              child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(
      BuildContext context, MyGardenController gardenController, MyGardenItem? gardenPlant) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.55,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5FAF6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 14),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCFDAD1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildPlantHeader(gardenPlant),
              ),
              const SizedBox(height: 20),

              // Stats row
              _buildStatsRow(gardenPlant),
              const SizedBox(height: 24),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildActionButtons(context, gardenController, gardenPlant),
              ),
              const SizedBox(height: 28),

              // Tabs
              _buildTabs(),
              const SizedBox(height: 4),

              // Tab content
              _buildTabContent(context, gardenController, gardenPlant),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlantHeader(MyGardenItem? gardenPlant) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.plant.scientificName != null)
                Text(
                  widget.plant.scientificName!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF5C8A63),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              if (widget.plant.scientificName != null) const SizedBox(height: 4),
              Text(
                gardenPlant?.nickname != null
                    ? '"${gardenPlant!.nickname}"'
                    : widget.plant.name,
                style: const TextStyle(
                  fontSize: 32,
                  height: 1.1,
                  color: Color(0xFF0D1F10),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.plant.shortDescription,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF6E8B73),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (gardenPlant != null)
          _HealthBadge(status: gardenPlant.healthStatus),
      ],
    );
  }

  Widget _buildStatsRow(MyGardenItem? gardenPlant) {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _StatCard(
            icon: Icons.wb_sunny_rounded,
            iconColor: const Color(0xFFE68A00),
            bgColor: const Color(0xFFFFF3E0),
            label: 'Ánh sáng',
            value: widget.plant.lightLevel,
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.water_drop_rounded,
            iconColor: const Color(0xFF1565C0),
            bgColor: const Color(0xFFE3F2FD),
            label: 'Tưới nước',
            value: gardenPlant?.wateringFrequencyLabel ?? widget.plant.waterNeed,
          ),
          const SizedBox(width: 12),
          if (widget.plant.temperatureRange != null)
            _StatCard(
              icon: Icons.thermostat_rounded,
              iconColor: const Color(0xFFB71C1C),
              bgColor: const Color(0xFFFFEBEE),
              label: 'Nhiệt độ',
              value: widget.plant.temperatureRange!,
            ),
          if (widget.plant.temperatureRange != null) const SizedBox(width: 12),
          _StatCard(
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFF2E7D32),
            bgColor: const Color(0xFFE8F5E9),
            label: 'Độ khó',
            value: widget.plant.difficulty,
          ),
          if (gardenPlant != null) ...[
            const SizedBox(width: 12),
            _StatCard(
              icon: Icons.calendar_today_rounded,
              iconColor: const Color(0xFF6A1B9A),
              bgColor: const Color(0xFFF3E5F5),
              label: 'Lần cuối',
              value: gardenPlant.lastWateredLabel,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, MyGardenController gardenController, MyGardenItem? gardenPlant) {
    if (gardenPlant == null) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () async {
            final bool added = await gardenController.addPlant(widget.plant.id);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  added
                      ? 'Đã thêm ${widget.plant.name} vào vườn của tôi 🌱'
                      : '${widget.plant.name} đã có trong vườn',
                ),
                backgroundColor: primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            );
          },
          icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
          label: const Text('Thêm vào vườn của tôi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _confirmWatering(context, gardenController, gardenPlant),
              icon: const Icon(Icons.water_drop_rounded, size: 20),
              label: const Text('Đã tưới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                elevation: 0,
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _confirmFertilizer(context, gardenController, gardenPlant),
              icon: const Icon(Icons.eco_rounded, size: 20),
              label: const Text('Bón phân'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 0,
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 56,
          width: 56,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEDF4EE),
              foregroundColor: primaryColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Icon(Icons.edit_rounded, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFE4EEE5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF5A7A60),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          indicator: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(14),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: const [
            Tab(text: 'Nhật ký'),
            Tab(text: 'Chăm sóc'),
            Tab(text: 'Thú vị'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, MyGardenController gardenController, MyGardenItem? gardenPlant) {
    return SizedBox(
      height: 600,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildCareLogTab(context, gardenController, gardenPlant),
          _buildCareGuideTab(),
          _buildFunFactsTab(),
        ],
      ),
    );
  }

  Widget _buildCareLogTab(BuildContext context, MyGardenController gardenController, MyGardenItem? gardenPlant) {
    if (gardenPlant == null) {
      return _buildEmptyState(
        icon: Icons.note_add_outlined,
        title: 'Chưa có nhật ký',
        subtitle: 'Thêm cây vào vườn để bắt đầu ghi nhật ký chăm sóc',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Growth timeline section
        if (gardenPlant.growthTimeline.isNotEmpty) ...[
          _buildSectionLabel('🌱 Dòng thời gian sinh trưởng'),
          const SizedBox(height: 12),
          SizedBox(
            height: 185,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: gardenPlant.growthTimeline.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == gardenPlant.growthTimeline.length) {
                  return _AddSnapshotCard(
                    onTap: () => _openAddSnapshotDialog(context, gardenController, gardenPlant),
                  );
                }
                return _GrowthSnapshotCard(snapshot: gardenPlant.growthTimeline[index]);
              },
            ),
          ),
          const SizedBox(height: 28),
        ] else ...[
          _buildSectionLabel('🌱 Dòng thời gian sinh trưởng'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _openAddSnapshotDialog(context, gardenController, gardenPlant),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFB5D1B9), width: 1.5, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Color(0xFF5A7A60), size: 20),
                  SizedBox(width: 8),
                  Text('Thêm ảnh sinh trưởng đầu tiên',
                      style: TextStyle(color: Color(0xFF5A7A60), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],

        _buildSectionLabel('📋 Lịch sử chăm sóc'),
        const SizedBox(height: 12),
        if (gardenPlant.careLogs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text('Chưa có lịch sử chăm sóc',
                  style: TextStyle(color: Color(0xFF8EA994))),
            ),
          )
        else
          ...gardenPlant.careLogs.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CareLogTile(entry: entry),
            ),
          ),
      ],
    );
  }

  Widget _buildCareGuideTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (widget.plant.description.isNotEmpty) ...[
          _buildSectionLabel('📖 Giới thiệu'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: Text(
              widget.plant.description,
              style: const TextStyle(fontSize: 14, height: 1.65, color: Color(0xFF3E5240)),
            ),
          ),
          const SizedBox(height: 24),
        ],
        _buildSectionLabel('✅ Hướng dẫn chăm sóc'),
        const SizedBox(height: 12),
        ...widget.plant.careGuide.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CareGuideTile(index: entry.key + 1, text: entry.value),
          ),
        ),
        if (widget.plant.toxicity != null) ...[
          const SizedBox(height: 16),
          _ToxicityCard(toxicity: widget.plant.toxicity!),
        ],
      ],
    );
  }

  Widget _buildFunFactsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSectionLabel('💡 Bạn có biết?'),
        const SizedBox(height: 12),
        ...widget.plant.funFacts.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FactCard(index: entry.key, text: entry.value),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: primaryColor),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0D1F10))),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6E8B73), height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0D2A12),
        letterSpacing: -0.2,
      ),
    );
  }

  void _confirmWatering(BuildContext context, MyGardenController controller, MyGardenItem? gardenPlant) {
    if (gardenPlant == null) {
      _showSnackBar('Vui lòng thêm cây vào vườn trước');
      return;
    }
    final log = PlantCareLogEntry(
      title: 'Đã tưới nước',
      timeLabel: 'Vừa xong',
      note: 'Người dùng vừa xác nhận tưới nước cho cây.',
      icon: Icons.water_drop_rounded,
      accentColor: const Color(0xFF1565C0),
    );
    controller.addCareLog(gardenPlant.id, log);
    _showSnackBar('Đã lưu nhật ký tưới nước 💧');
  }

  void _confirmFertilizer(BuildContext context, MyGardenController controller, MyGardenItem? gardenPlant) {
    if (gardenPlant == null) {
      _showSnackBar('Vui lòng thêm cây vào vườn trước');
      return;
    }
    final log = PlantCareLogEntry(
      title: 'Bón phân hữu cơ',
      timeLabel: 'Vừa xong',
      note: 'Người dùng vừa xác nhận bón phân cho cây.',
      icon: Icons.eco_rounded,
      accentColor: const Color(0xFF2E7D32),
    );
    controller.addCareLog(gardenPlant.id, log);
    _showSnackBar('Đã lưu nhật ký bón phân 🌿');
  }

  Future<void> _openAddSnapshotDialog(BuildContext context, MyGardenController controller, MyGardenItem gardenPlant) async {
    final String currentMonth = 'Tháng ${DateTime.now().month}';
    _monthController.text = currentMonth;
    _imageController.text = widget.plant.imageUrl;
    _noteController.text = '';

    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddSnapshotSheet(
        monthController: _monthController,
        imageController: _imageController,
        noteController: _noteController,
      ),
    );

    if (saved != true || !context.mounted) return;

    final snapshot = PlantGrowthSnapshot(
      monthLabel: _monthController.text.trim().isEmpty ? currentMonth : _monthController.text.trim(),
      imageUrl: _imageController.text.trim().isEmpty ? widget.plant.imageUrl : _imageController.text.trim(),
      note: _noteController.text.trim().isEmpty ? 'Người dùng vừa cập nhật ảnh mới.' : _noteController.text.trim(),
    );
    controller.addGrowthSnapshot(gardenPlant.id, snapshot);
    _showSnackBar('Đã thêm ảnh sinh trưởng mới 🌱');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1B3A1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUBWIDGETS
// ─────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.32),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: child,
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  const _HealthBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
        ),
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(color: const Color(0xFF43A047).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            status,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF8FA897), letterSpacing: 0.5),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1A2E1D), height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _CareGuideTile extends StatelessWidget {
  const _CareGuideTile({required this.index, required this.text});
  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF3A5040)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToxicityCard extends StatelessWidget {
  const _ToxicityCard({required this.toxicity});
  final String toxicity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lưu ý về độc tính',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF5D3A00))),
                const SizedBox(height: 4),
                Text(toxicity, style: const TextStyle(fontSize: 13, height: 1.55, color: Color(0xFF6D4C00))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({required this.index, required this.text});
  final int index;
  final String text;

  static const List<List<Color>> _gradients = [
    [Color(0xFF1A237E), Color(0xFF283593)],
    [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    [Color(0xFF4A148C), Color(0xFF6A1B9A)],
    [Color(0xFF0D47A1), Color(0xFF1565C0)],
    [Color(0xFF880E4F), Color(0xFFC2185B)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[index % _gradients.length];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _CareLogTile extends StatelessWidget {
  const _CareLogTile({required this.entry});
  final PlantCareLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: entry.accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(entry.icon, color: entry.accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF132A18)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF4EE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.timeLabel,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF4A7A50), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                if (entry.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.note,
                    style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF65806A)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthSnapshotCard extends StatelessWidget {
  const _GrowthSnapshotCard({required this.snapshot});
  final PlantGrowthSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: Image.network(
                snapshot.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE8EFE7),
                  alignment: Alignment.center,
                  child: const Icon(Icons.photo_library_outlined, color: primaryColor, size: 32),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    snapshot.monthLabel,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  snapshot.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF55675A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddSnapshotCard extends StatelessWidget {
  const _AddSnapshotCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFEDF4EE),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF9EC5A3), width: 1.5, style: BorderStyle.solid),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: Color(0xFF4A7A50), size: 28),
            SizedBox(height: 10),
            Text('Thêm ảnh', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A7A50))),
          ],
        ),
      ),
    );
  }
}

class _AddSnapshotSheet extends StatelessWidget {
  const _AddSnapshotSheet({
    required this.monthController,
    required this.imageController,
    required this.noteController,
  });

  final TextEditingController monthController;
  final TextEditingController imageController;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5FAF6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: const Color(0xFFCFDAD1), borderRadius: BorderRadius.circular(99)),
            ),
          ),
          const SizedBox(height: 22),
          const Text('Thêm ảnh sinh trưởng',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0D2A12))),
          const SizedBox(height: 20),
          _SheetField(controller: monthController, label: 'Mốc thời gian', hint: 'Ví dụ: Tháng 4'),
          const SizedBox(height: 14),
          _SheetField(controller: imageController, label: 'URL hình ảnh', hint: 'Dán link ảnh cây'),
          const SizedBox(height: 14),
          _SheetField(controller: noteController, label: 'Ghi chú', hint: 'Mô tả thay đổi trong tháng này', maxLines: 3),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: Color(0xFFB5D1B9)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Lưu ảnh', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF3A6040), letterSpacing: 0.4)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFABC4AF)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
      ],
    );
  }
}
