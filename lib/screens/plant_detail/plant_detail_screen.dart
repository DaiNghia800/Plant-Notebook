import 'package:flutter/material.dart';
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

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _monthController.dispose();
    _imageController.dispose();
    _noteController.dispose();
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

        return Scaffold(
          backgroundColor: neutral,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: neutral,
                elevation: 0,
                title: Text(
                  widget.plant.name,
                  style: const TextStyle(
                    color: Color(0xFF11331A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                iconTheme: const IconThemeData(color: Color(0xFF11331A)),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.plant.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFE6EFE8),
                            child: const Icon(
                              Icons.local_florist,
                              size: 80,
                              color: primaryColor,
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xA6000000)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -36),
                        child: _OverviewCard(
                          plant: widget.plant,
                          gardenPlant: gardenPlant,
                          onWateringConfirmed: () => _confirmWatering(context, gardenController, gardenPlant),
                          onEditInfo: _showEditInfoMessage,
                        ),
                      ),
                      const SizedBox(height: 2),
                      
                      if (gardenPlant != null) ...[
                        _SectionHeader(
                          title: 'Thống kê & Nhật ký',
                          subtitle:
                              'Theo dõi các lần chăm sóc và ảnh cập nhật của cây theo từng tháng.',
                        ),
                        const SizedBox(height: 12),
                        _PanelCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Nhật ký chăm sóc',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF14311F),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _showQuickActionsHint,
                                    child: const Text('Xác nhận nhanh'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionButton(
                                      label: 'Đã tưới',
                                      icon: Icons.water_drop_rounded,
                                      onTap: () => _confirmWatering(context, gardenController, gardenPlant),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _ActionButton(
                                      label: 'Đã bón phân',
                                      icon: Icons.eco_rounded,
                                      secondary: true,
                                      onTap: () => _confirmFertilizer(context, gardenController, gardenPlant),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ...gardenPlant.careLogs.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _CareLogTile(entry: entry),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _PanelCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Dòng thời gian sinh trưởng',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF14311F),
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _openAddSnapshotDialog(context, gardenController, gardenPlant),
                                    icon: const Icon(Icons.add_a_photo_outlined),
                                    label: const Text('Thêm ảnh tháng'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (gardenPlant.growthTimeline.isEmpty)
                                const Text('Chưa có ảnh sinh trưởng nào.')
                              else
                                SizedBox(
                                  height: 220,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: gardenPlant.growthTimeline.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final PlantGrowthSnapshot snapshot =
                                          gardenPlant.growthTimeline[index];
                                      return _GrowthSnapshotCard(snapshot: snapshot);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      _SectionHeader(
                        title: 'Hướng dẫn chăm sóc',
                        subtitle:
                            'Tóm tắt những lưu ý quan trọng để cây giữ dáng và phát triển đều.',
                      ),
                      const SizedBox(height: 12),
                      _PanelCard(
                        child: Column(
                          children: widget.plant.careGuide
                              .map(
                                (tip) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F4EA),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.lightbulb_outline_rounded,
                                          size: 18,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          tip,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.55,
                                            color: Color(0xFF3E4E43),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionHeader(
                        title: 'Bạn có biết?',
                        subtitle:
                            'Những điểm thú vị giúp người dùng hiểu cây nhanh hơn trước khi chăm sóc.',
                      ),
                      const SizedBox(height: 12),
                      _PanelCard(
                        child: Column(
                          children: widget.plant.funFacts
                              .map(
                                (fact) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _FactRow(text: fact),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: gardenPlant != null
                              ? null
                              : () async {
                                  final bool added = await gardenController
                                      .addPlant(widget.plant.id);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        added
                                            ? 'Đã thêm ${widget.plant.name} vào vườn của tôi'
                                            : '${widget.plant.name} đã có trong vườn',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                          icon: Icon(
                            gardenPlant != null
                                ? Icons.check_circle_rounded
                                : Icons.add_circle_outline,
                          ),
                          label: Text(
                            gardenPlant != null
                                ? 'Đã có trong vườn của tôi'
                                : 'Thêm vào vườn của tôi',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmWatering(BuildContext context, MyGardenController controller, MyGardenItem? gardenPlant) {
    if (gardenPlant == null) {
      _showSnackBar('Vui lòng thêm cây vào vườn trước khi ghi nhật ký.');
      return;
    }

    final log = PlantCareLogEntry(
      title: 'Đã tưới nước',
      timeLabel: 'Vừa xong',
      note: 'Người dùng vừa xác nhận tưới nước cho cây.',
      icon: Icons.water_drop_rounded,
      accentColor: const Color(0xFF1B7A3D),
    );

    controller.addCareLog(gardenPlant.id, log);
    _showSnackBar('Đã lưu nhật ký tưới nước cho ${widget.plant.name}.');
  }

  void _confirmFertilizer(BuildContext context, MyGardenController controller, MyGardenItem? gardenPlant) {
    if (gardenPlant == null) {
      _showSnackBar('Vui lòng thêm cây vào vườn trước khi ghi nhật ký.');
      return;
    }

    final log = PlantCareLogEntry(
      title: 'Bón phân hữu cơ',
      timeLabel: 'Vừa xong',
      note: 'Người dùng vừa xác nhận bón phân cho cây.',
      icon: Icons.eco_rounded,
      accentColor: const Color(0xFF6C8F49),
    );

    controller.addCareLog(gardenPlant.id, log);
    _showSnackBar('Đã lưu nhật ký bón phân cho ${widget.plant.name}.');
  }

  Future<void> _openAddSnapshotDialog(BuildContext context, MyGardenController controller, MyGardenItem gardenPlant) async {
    final String currentMonth = 'Tháng ${DateTime.now().month}';
    _monthController.text = currentMonth;
    _imageController.text = widget.plant.imageUrl;
    _noteController.text = '';

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm ảnh sinh trưởng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _monthController,
                  decoration: const InputDecoration(
                    labelText: 'Mốc thời gian',
                    hintText: 'Ví dụ: Tháng 4',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _imageController,
                  decoration: const InputDecoration(
                    labelText: 'URL hình ảnh',
                    hintText: 'Dán link ảnh cây',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    hintText: 'Mô tả thay đổi của cây trong tháng này',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Lưu ảnh'),
            ),
          ],
        );
      },
    );

    if (saved != true || !context.mounted) {
      return;
    }

    final snapshot = PlantGrowthSnapshot(
      monthLabel: _monthController.text.trim().isEmpty
          ? currentMonth
          : _monthController.text.trim(),
      imageUrl: _imageController.text.trim().isEmpty
          ? widget.plant.imageUrl
          : _imageController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? 'Người dùng vừa cập nhật ảnh mới cho cây.'
          : _noteController.text.trim(),
    );

    controller.addGrowthSnapshot(gardenPlant.id, snapshot);
    _showSnackBar('Đã thêm ảnh sinh trưởng mới.');
  }

  void _showEditInfoMessage() {
    _showSnackBar('Tính năng chỉnh sửa thông tin đang được hoàn thiện.');
  }

  void _showQuickActionsHint() {
    _showSnackBar('Chạm vào Đã tưới hoặc Đã bón phân để lưu nhật ký nhanh.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.plant,
    required this.gardenPlant,
    required this.onWateringConfirmed,
    required this.onEditInfo,
  });

  final LibraryPlantItem plant;
  final MyGardenItem? gardenPlant;
  final VoidCallback onWateringConfirmed;
  final VoidCallback onEditInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: const TextStyle(
                        fontSize: 34,
                        height: 1.02,
                        color: Color(0xFF111C14),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${plant.shortDescription}"',
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF2D6B3A),
                      ),
                    ),
                  ],
                ),
              ),
              if (gardenPlant != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF94EA91),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF12612D),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        gardenPlant!.healthStatus,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF11331A),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              if (gardenPlant != null) ...[
                Expanded(
                  child: _StatTile(
                    label: 'WATERING',
                    value: gardenPlant!.wateringFrequencyLabel,
                    icon: Icons.water_drop_rounded,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: _StatTile(
                  label: 'LIGHT',
                  value: plant.lightLevel,
                  icon: Icons.wb_sunny_rounded,
                ),
              ),
              if (gardenPlant != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    label: 'LAST WATER',
                    value: gardenPlant!.lastWateredLabel,
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
              ],
            ],
          ),
          if (gardenPlant != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onWateringConfirmed,
                icon: const Icon(Icons.water_drop_outlined),
                label: const Text('Đã tưới'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF126D25),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onEditInfo,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Chỉnh sửa thông tin'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: Color(0xFFDBE7DC)),
                  backgroundColor: const Color(0xFFF1F6F2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5,
          height: 26,
          margin: const EdgeInsets.only(top: 4, right: 10),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF102A17),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF587064),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1ECE3)),
      ),
      child: child,
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6F1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1EAE2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: primaryColor),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w800,
              color: Color(0xFF73847A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: Color(0xFF122A18),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.secondary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final Color foreground = secondary ? primaryColor : Colors.white;
    final Color background = secondary ? const Color(0xFFE6EFE7) : primaryColor;

    return SizedBox(
      height: 50,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _CareLogTile extends StatelessWidget {
  const _CareLogTile({required this.entry});

  final PlantCareLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: entry.accentColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(entry.icon, color: entry.accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF132A18),
                      ),
                    ),
                  ),
                  Text(
                    entry.timeLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF708174),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                entry.note,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF55675A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GrowthSnapshotCard extends StatelessWidget {
  const _GrowthSnapshotCard({required this.snapshot});

  final PlantGrowthSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1EAE2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SizedBox(
              height: 128,
              width: double.infinity,
              child: Image.network(
                snapshot.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE8EFE7),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: primaryColor,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.monthLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF132A18),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  snapshot.note,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Color(0xFF55675A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4EA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF3E4E43),
            ),
          ),
        ),
      ],
    );
  }
}
