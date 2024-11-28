import 'dart:io';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart' as pdfx; // Pour le rendu des PDFs
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion; // Pour l'extraction de texte
import '../home/data/ListeningController.dart';
import 'Transalting_content.dart';


class Translating extends StatefulWidget {
  final String pdfPath; // URL du PDF
  final String? selectedLanguage;

  const Translating({Key? key, required this.pdfPath, this.selectedLanguage})
      : super(key: key);

  @override
  _PdfViewer3DState createState() => _PdfViewer3DState();
}

class _PdfViewer3DState extends State<Translating>
    with SingleTickerProviderStateMixin {
  late ListeningController controller;
  late PdfController pdfController;
  String? selectedLanguage;
  String extractedText = '';
  RxBool isLoading = true.obs;
  bool loadingError = false;
  File? downloadedPdfFile;

  int totalPages = 0;
  var currentPage = 1.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ListeningController(pdfPath: widget.pdfPath));
    String? selectedLanguage;
    _initializePdf(); // Initialisation au lancement
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<File> _downloadPdf(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = Directory.systemTemp;
        final fileName =
            'downloaded_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = join(directory.path, fileName);
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Échec du téléchargement du PDF');
      }
    } catch (e) {
      throw Exception('Erreur lors du téléchargement du PDF : $e');
    }
  }

  Future<void> _initializePdf() async {
    try {
      // Télécharger le PDF et sauvegarder localement
      downloadedPdfFile = await _downloadPdf(widget.pdfPath);

      // Ouvrir le PDF pour rendu et extraction de texte
      final pdfDocument = await pdfx.PdfDocument.openFile(downloadedPdfFile!.path);
      pdfController = PdfController(
        document: Future.value(pdfDocument),
        initialPage: 1,
      );

      totalPages = pdfDocument.pagesCount;
      isLoading.value = false;
      loadingError = false;

      // Charger le texte de la première page après initialisation
      loadTextFromPdf();
    } catch (e) {
      loadingError = true;
      isLoading.value = false;
      print('Erreur lors du chargement du PDF : $e');
    }
  }

  void loadTextFromPdf() {
    if (downloadedPdfFile == null) {
      print("Le fichier PDF n'a pas encore été téléchargé.");
      return;
    }

    try {
      // Charger le fichier PDF téléchargé
      final document = syncfusion.PdfDocument(inputBytes: downloadedPdfFile!.readAsBytesSync());

      // Extraire le texte de la page actuelle
      final text = syncfusion.PdfTextExtractor(document).extractText(startPageIndex: currentPage.value - 1);

      // Afficher le texte extrait dans la console
      print("Texte extrait de la page ${currentPage.value} :\n$text");

      // Mettre à jour extractedText avec le texte extrait
      setState(() {
        extractedText = text;  // Enregistrer le texte extrait
      });

      // Libérer les ressources du document
      document.dispose();
    } catch (e) {
      print("Erreur lors de l'extraction du texte : $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (loadingError) {
          return const Center(child: Text('Erreur lors du chargement du PDF'));
        } else {
          return Stack(
            children: [
              PdfView(
                controller: pdfController,
                onPageChanged: (page) {
                  setState(() {
                    currentPage = page.obs;
                  });
                  loadTextFromPdf(); // Charger le texte de la page
                },
              ),
              // Bouton flottant
              Positioned(
                bottom: screenHeight * 0.07,
                right: screenWidth * 0.05,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.language,
                      color: Color(0xFFD4B79F), size: 30),
                  onPressed: showLanguageSelectionDialog,
                ),
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
                      "Page $currentPage / $totalPages",
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

  void showLanguageSelectionDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Choose Language".tr),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text("English".tr),
                    value: "English US",
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text("French".tr),
                    value: "French",
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text("Spanish".tr),
                    value: "Spanish",
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text("Arabic".tr),
                    value: "Arabic",
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Cancel".tr),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text("OK".tr),
                  onPressed: () {
                    loadTextFromPdf();
                    // Afficher la valeur de selectedLanguage dans la console
                    print("Langue sélectionnée: $selectedLanguage");

                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TranslatingContentPage(
                          extractedText: extractedText,
                          selectedLanguage:selectedLanguage!,

                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
