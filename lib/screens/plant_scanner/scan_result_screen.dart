import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:plant_notebook/controller/plant_scanner_controller.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/result_area/result_sliver_app_bar.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/result_area/result_info_card.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/result_area/result_states.dart';

class ScanResultScreen extends StatefulWidget {
  final String imagePath;

  const ScanResultScreen({super.key, required this.imagePath});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantScannerController>().analyzeImage(widget.imagePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          ResultSliverAppBar(imagePath: widget.imagePath),
          SliverToBoxAdapter(
            child: Consumer<PlantScannerController>(
              builder: (context, controller, child) {
                return _buildBody(controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PlantScannerController controller) {
    if (controller.isAnalyzing) {
      return const ResultLoadingState();
    }

    if (controller.analysisErrorMessage != null) {
      return ResultErrorState(
        errorMessage: controller.analysisErrorMessage!,
        onRetry: () {
          controller.analyzeImage(widget.imagePath);
        },
      );
    }

    final data = controller.analysisResult;
    if (data == null) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.tenPhoThong,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.tenKhoaHoc,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ResultInfoCard(
            icon: Icons.health_and_safety,
            iconColor: Colors.blue,
            title: 'Tình trạng sức khỏe',
            content: data.tinhTrangSucKhoe,
          ),
          const SizedBox(height: 16),
          ResultInfoCard(
            icon: Icons.bug_report,
            iconColor: Colors.orange,
            title: 'Bệnh đang gặp',
            content: data.benhDangGap,
          ),
          const SizedBox(height: 16),
          ResultInfoCard(
            icon: Icons.lightbulb,
            iconColor: Colors.amber,
            title: 'Lời khuyên chăm sóc',
            content: data.loiKhuyenChamSoc,
          ),
          const SizedBox(height: 16),
          ResultInfoCard(
            icon: Icons.auto_awesome,
            iconColor: Colors.purple,
            title: 'Bạn có biết',
            content: data.banCoBiet,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
