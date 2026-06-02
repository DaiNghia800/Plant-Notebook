const fs = require('fs');
const path = 'd:/BTL_Mobile/Plant-Notebook/lib/screens/plant_detail/plant_detail_screen.dart';
const lines = fs.readFileSync(path, 'utf8').split('\n');

const newContent = `                      _OverviewCard(
                        plant: widget.plant,
                        gardenPlant: gardenPlant,
                        onWateringConfirmed: () => _confirmWatering(
                          context,
                          gardenController,
                          gardenPlant,
                        ),
                        onEditInfo: _showEditInfoMessage,
                        showActions: isAdded,
                      ),
                      if (isAdded && gardenPlant != null) ...[
                        const SizedBox(height: 24),
                        const _SectionHeader(
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
                                      onTap: () => _confirmWatering(
                                        context,
                                        gardenController,
                                        gardenPlant,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _ActionButton(
                                      label: 'Đã bón phân',
                                      icon: Icons.eco_rounded,
                                      secondary: true,
                                      onTap: () => _confirmFertilizer(
                                        context,
                                        gardenController,
                                        gardenPlant,
                                      ),
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
                                    onPressed: () => _openAddSnapshotDialog(
                                      context,
                                      gardenController,
                                      gardenPlant,
                                    ),
                                    icon: const Icon(Icons.add_a_photo_outlined),
                                    label: const Text('Thêm ảnh tháng'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 255,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: gardenPlant.growthTimeline.length,
                                  separatorBuilder: (context, index) =>
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
                      ],
                      const SizedBox(height: 16),
                      const _SectionHeader(
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
                                        width: 24,
                                        height: 24,
                                        margin: const EdgeInsets.only(top: 2),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE8F4EA),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          size: 14,
                                          color: Color(0xFF126D25),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          tip,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.45,
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
                      const _SectionHeader(
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
                          onPressed: isAdded
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
                                            ? 'Đã thêm ' + widget.plant.name + ' vào vườn của tôi'
                                            : widget.plant.name + ' đã có trong vườn',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                          icon: Icon(
                            isAdded
                                ? Icons.check_circle_rounded
                                : Icons.add_circle_outline,
                          ),
                          label: Text(
                            isAdded
                                ? 'Đã có trong vườn của tôi'
                                : 'Thêm vào vườn của tôi',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF126D25),
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
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }`.split('\n');

const outLines = [...lines.slice(0, 107), ...newContent, ...lines.slice(403)];

fs.writeFileSync(path, outLines.join('\n'));

// Now fix _OverviewCard missing parens
const path2 = 'd:/BTL_Mobile/Plant-Notebook/lib/screens/plant_detail/plant_detail_screen.dart';
let content2 = fs.readFileSync(path2, 'utf8');

// Fix missing Expanded paren
content2 = content2.replace(`                  value: showActions ? lastWateredLabel : plant.difficulty,
                  icon: showActions
                      ? Icons.calendar_month_rounded
                      : Icons.star_rounded,
                ),
              ],`, `                  value: showActions ? (gardenPlant?.lastWateredLabel ?? 'Chưa rõ') : plant.difficulty,
                  icon: showActions
                      ? Icons.calendar_month_rounded
                      : Icons.star_rounded,
                ),
              ),
            ],`);

fs.writeFileSync(path2, content2);
console.log('Done!');
