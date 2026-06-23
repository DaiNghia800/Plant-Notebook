import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

class ResultSliverAppBar extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;

  const ResultSliverAppBar({super.key, this.imagePath, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = const SizedBox();
    if (imagePath != null && imagePath!.isNotEmpty) {
      if (imagePath!.startsWith('http://') || imagePath!.startsWith('https://')) {
        imageWidget = Image.network(imagePath!, fit: BoxFit.cover);
      } else {
        imageWidget = Image.file(File(imagePath!), fit: BoxFit.cover);
      }
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = Image.network(imageUrl!, fit: BoxFit.cover);
    }

    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: const Color(0xFF2E7D32),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            imageWidget,
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent, Colors.black87],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ],
        ),
        title: Text(
          context.watch<ProfileController>().tr('analysis_result'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
