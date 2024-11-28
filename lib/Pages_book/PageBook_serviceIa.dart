import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import 'package:trrr/Pages_book/SummaryPage.dart';
import '../home/data/ListeningController.dart';
import 'ChattingPage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';// Import the ChattingPage

class PdfViewer3D extends StatefulWidget {
  final String pdfPath;

  const PdfViewer3D({Key? key, required this.pdfPath}) : super(key: key);

  @override
  _PdfViewer3DState createState() => _PdfViewer3DState();
}

class _PdfViewer3DState extends State<PdfViewer3D> with SingleTickerProviderStateMixin {
  late ListeningController controller;
  var bookTitle="";
  var pdfpath="";

  @override
  void initState() {
    super.initState();
    // Passer le chemin du PDF au contrôleur
    controller = Get.put(ListeningController(pdfPath: widget.pdfPath));
    bookTitle=Get.arguments[0];
    pdfpath=Get.arguments[1];
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

    // Calcul des espacements dynamiques en fonction de la taille de l'écran
    double iconSize = screenWidth * 0.1; // Taille dynamique de l'icône de chat
    double bottomPadding = screenHeight * 0.07; // Espacement en bas pour l'icône de chat
    double pageNumberHeight = screenHeight * 0.05; // Hauteur de la barre de numéros de page

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

              // Chatbot Icon Positioned Above the Page Number
              Positioned(
                bottom: bottomPadding, // Positionner l'icône vers le bas de la page
                right: screenWidth * 0.05, // Positionner à 5% de la largeur de l'écran à droite
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Couleur de fond du conteneur
                    shape: BoxShape.circle, // Conteneur avec des bords arrondis
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Ombre légère
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(iconSize * 0.25), // Espacement à l'intérieur du conteneur
                  child: IconButton(
                    icon: Icon(
                      CupertinoIcons.chat_bubble_fill,
                      color: Color(0xFFD4B79F),
                      size: iconSize, // Taille de l'icône agrandie dynamiquement
                    ),
                    onPressed: () {

                      Get.to(()=> ChattingPage() , arguments:[bookTitle,pdfpath]);
                    },
                  ),
                ),
              ),

              // Page Number Positioned at the Bottom
              Positioned(
                bottom: pageNumberHeight, // Hauteur dynamique pour la barre de numéros de page
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
