import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../home/data/ListeningController.dart';
import 'SummaryPage.dart';

class SummarizingPage extends StatefulWidget {
  final String pdfPath;

  const SummarizingPage({Key? key, required this.pdfPath}) : super(key: key);

  @override
  _PdfViewer3DState createState() => _PdfViewer3DState();
}

class _PdfViewer3DState extends State<SummarizingPage> with SingleTickerProviderStateMixin {
  late ListeningController controller;


  @override
  void initState() {
    super.initState();
    // Passer le chemin du PDF au contrôleur
    controller = Get.put(ListeningController(pdfPath: widget.pdfPath));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (controller.loadingError) {
          return const Center(
            child: Text('Erreur lors du chargement du PDF'),
          );
        } else if (controller.pdfController == null) {
          return const Center(
            child: Text('PDF non initialisé'),
          );
        } else {
          return Stack(
            children: [
              AnimatedBuilder(
                animation: controller.foldAnimation,
                builder: (context, child) {
                  final isFoldingPage = controller.foldAnimation.value < 1;
                  final rotationAngle = isFoldingPage
                      ? controller.foldAnimation.value * (math.pi / 2)
                      : (1 - controller.foldAnimation.value) * (math.pi / 2);

                  return Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(rotationAngle),
                    child: PdfView(
                      key: ValueKey<int>(controller.currentPage.value),
                      controller: controller.pdfController!,
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (page) {
                        controller.goToPage(page);
                      },
                    ),
                  );
                },
              ),
              Positioned(
                bottom: screenHeight * 0.07,
                right: screenWidth * 0.05,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: IconButton(
                    icon: const Icon(
                      Icons.description,
                      color: Color(0xFFD4B79F),
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SummaryPage(pdfPath: widget.pdfPath),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Page ${controller.currentPage.value} / ${controller.totalPages}",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
