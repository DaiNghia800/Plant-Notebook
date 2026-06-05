import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

class ScanStatusChip extends StatefulWidget {
  final String? label;

  const ScanStatusChip({super.key, this.label});

  @override
  State<ScanStatusChip> createState() => _ScanStatusChipState();
}

class _ScanStatusChipState extends State<ScanStatusChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fade = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withOpacity(0.85),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF81C784).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFA5D6A7),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.label ?? context.watch<ProfileController>().tr('analyzing_plant'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
