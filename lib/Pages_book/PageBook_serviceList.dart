import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import '/home/data/ListeningController.dart';
import 'package:http/http.dart' as http;

class ListeningViewer extends StatefulWidget {
  final String pdfPath; // URL du PDF sur le serveur

  const ListeningViewer({Key? key, required this.pdfPath}) : super(key: key);

  @override
  _ListeningViewerState createState() => _ListeningViewerState();
}

class _ListeningViewerState extends State<ListeningViewer> with SingleTickerProviderStateMixin {
  late ListeningController controller;
  late FlutterTts flutterTts;

  bool isPlaying = false; // Variable pour savoir si la lecture est en cours

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();

    // Initialisation du contrôleur de la page
    controller = Get.put(ListeningController(pdfPath: widget.pdfPath));
  }

  @override
  void dispose() {
    // Arrêter la lecture et libérer les ressources
    controller.onStopPressed();
    controller.dispose();
    super.dispose();
  }

  /// Alterner entre lecture et arrêt
  void _togglePlayStop() {
    if (isPlaying) {
      controller.onStopPressed(); // Arrêter la lecture
    } else {
      controller.onPlayPressed(); // Démarrer la lecture
    }
    setState(() {
      isPlaying = !isPlaying; // Mettre à jour l'état
    });
  }
  Future<String> fetchTranslation(String text, String selectedLanguage) async {
    final targetLang = _mapLanguageToCode(selectedLanguage);

    final response = await http.post(
      Uri.parse('https://sd3.savooria.com/translate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'text': text, 'targetLang': targetLang}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['translatedText'] ?? 'Translation not available';
    } else {
      return 'Failed to load translation';
    }
  }

  String _mapLanguageToCode(String selectedLanguage) {
    switch (selectedLanguage.toLowerCase()) {
      case 'french':
      case 'fr':
        return 'fr';
      case 'english':
      case 'en':
        return 'en';
      case 'spanish':
      case 'es':
        return 'es';
      case 'arabic':
      case 'ar':
        return 'ar';
      default:
        return 'en'; // Default to English
    }
  }





  @override
  Widget build(BuildContext context) {
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
              // Affichage du PDF avec effet de pliage
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

              // Indicateur de page
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

              // Boutons flottants pour la lecture et la sélection de langue
              Positioned(
                bottom: 60,
                right: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton pour lecture/arrêt
                    FloatingActionButton(
                      onPressed: _togglePlayStop,
                      backgroundColor: isPlaying ? Colors.red : const Color(0xFF96D6EB),
                      child: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                    ),

                    const SizedBox(width: 16),

                    // Bouton pour sélection de langue
                    FloatingActionButton(
                      onPressed: () => controller.showLanguageSelectionDialog(),
                      backgroundColor: const Color(0xFFFCFCF7),
                      child: const Icon(Icons.language),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}