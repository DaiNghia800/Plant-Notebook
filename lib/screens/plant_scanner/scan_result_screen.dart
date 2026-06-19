import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

import 'package:plant_notebook/controller/plant_scanner_controller.dart';
import 'package:plant_notebook/data/services/plant_scanner_service.dart';
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
    final lang = context.watch<ProfileController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          ResultSliverAppBar(imagePath: widget.imagePath),
          SliverToBoxAdapter(
            child: Consumer<PlantScannerController>(
              builder: (context, controller, child) {
                return _buildBody(controller, lang);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PlantScannerController controller, ProfileController lang) {
    if (controller.isAnalyzing) {
      return const ResultLoadingState();
    }

    if (controller.analysisErrorMessage != null) {
      return ResultErrorState(
        errorMessage: controller.analysisErrorMessage!,
        onRetry: () {
          // Xóa cooldown để retry bắt đầu lại
          PlantScannerService.clearCooldowns();
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
            title: lang.tr('health_status'),
            content: data.tinhTrangSucKhoe,
          ),
          const SizedBox(height: 16),
          ResultInfoCard(
            icon: Icons.bug_report,
            iconColor: Colors.orange,
            title: lang.tr('diseases'),
            content: data.benhDangGap,
          ),
          const SizedBox(height: 16),
          ResultInfoCard(
            icon: Icons.lightbulb,
            iconColor: Colors.amber,
            title: lang.tr('care_advice'),
            content: data.loiKhuyenChamSoc,
          ),
          const SizedBox(height: 16),
          ResultInfoCard(
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.red,
            title: lang.tr('toxicity'),
            content: data.toxicity,
          ),
          const SizedBox(height: 16),
          ResultInfoCard(
            icon: Icons.thermostat_rounded,
            iconColor: Colors.redAccent,
            title: lang.tr('temperature_label'),
            content: data.temperature,
          ),
          const SizedBox(height: 16),
          ResultInfoCard(
            icon: Icons.water_drop_rounded,
            iconColor: Colors.teal,
            title: lang.tr('humidity_label'),
            content: data.humidity,
          ),
          const SizedBox(height: 16),
          ResultInfoCard(
            icon: Icons.light_mode_rounded,
            iconColor: Colors.orangeAccent,
            title: lang.tr('light_level'),
            content: data.lightLevel,
          ),
          const SizedBox(height: 16),
          ResultInfoCard(
            icon: Icons.opacity_rounded,
            iconColor: Colors.blueAccent,
            title: lang.tr('water_need'),
            content: data.waterNeed,
          ),
          const SizedBox(height: 16),
          ResultInfoCard(
            icon: Icons.star_half_rounded,
            iconColor: Colors.brown,
            title: lang.tr('difficulty'),
            content: data.difficulty,
          ),
          const SizedBox(height: 16),
          ResultInfoCard(
            icon: Icons.auto_awesome,
            iconColor: Colors.purple,
            title: lang.tr('did_you_know'),
            content: data.banCoBiet,
          ),
          if (!controller.existsInLibrary) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFA5D6A7),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        controller.proposalSubmitted
                            ? Icons.check_circle_rounded
                            : Icons.add_moderator_rounded,
                        color: const Color(0xFF2E7D32),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.proposalSubmitted
                              ? lang.tr('proposal_sent_success')
                              : lang.tr('plant_not_in_library'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    controller.proposalSubmitted
                        ? lang.tr('proposal_desc').replaceAll('{name}', data.tenPhoThong)
                        : lang.tr('ask_propose'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2E7D32),
                      height: 1.4,
                    ),
                  ),
                  if (!controller.proposalSubmitted) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                        ),
                        onPressed: controller.isSubmittingProposal
                            ? null
                            : () async {
                                try {
                                  await controller.submitProposal(widget.imagePath);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(lang.tr('propose_success_msg').replaceAll('{name}', data.tenPhoThong)),
                                        backgroundColor: const Color(0xFF2E7D32),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(lang.tr('propose_error').replaceAll('{error}', e.toString())),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                        icon: controller.isSubmittingProposal
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          controller.isSubmittingProposal
                              ? lang.tr('sending_proposal')
                              : lang.tr('send_admin_request'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
