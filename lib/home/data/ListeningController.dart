import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;

import '../model/book.dart';

class ListeningController extends GetxController with GetTickerProviderStateMixin {
  late PdfController? pdfController;
  late FlutterTts flutterTts;
  final String pdfPath; // URL of the PDF à charger
  int totalPages = 0;
  var currentPage = 1.obs;
  bool loadingError = false;
  var isLoading = true.obs;
  late AnimationController animationController;
  late Animation<double> foldAnimation;
  String? selectedLanguage;
  File? downloadedPdfFile;
  String extractedText = '';
  String translatedText = ''; // Texte traduit

  ListeningController({required this.pdfPath});

  @override
  Future<void> onInit() async {
    super.onInit();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    foldAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
    flutterTts = FlutterTts();

    _initializePdf();
  }

  Future<void> _initializePdf() async {
    try {
      downloadedPdfFile = await _downloadPdf(pdfPath);
      final pdfDocument = await PdfDocument.openFile(downloadedPdfFile!.path);
      pdfController = PdfController(
        document: Future.value(pdfDocument),
        initialPage: 1,
      );

      totalPages = pdfDocument.pagesCount;
      isLoading.value = false;
      loadingError = false;
    } catch (e) {
      loadingError = true;
      isLoading.value = false;
      print('Error loading PDF: $e');
    }
  }

  Future<File> _downloadPdf(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = Directory.systemTemp;
        final fileName = 'downloaded_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = join(directory.path, fileName);
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      throw Exception('Error downloading PDF: $e');
    }
  }

  // Naviguer vers une page spécifique
  void goToPage(int page) {
    if (currentPage.value != page) {
      currentPage.value = page;
      pdfController?.animateToPage(
        page,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      animationController.forward(from: 0.0);
      loadTextFromPdf(); // Charger le texte après navigation
    }
  }

  void onPlayPressed() async {
    print("Selected languageeee: $selectedLanguage"); // Log pour vérifier la langue sélectionnée
    if (selectedLanguage == null || selectedLanguage!.isEmpty) {
      print("Please select a language first!");
      return;
    }

    if (downloadedPdfFile == null) {
      print("PDF not downloaded or available!");
      return;
    }

    // Extraire le texte de la page actuelle
    loadTextFromPdf();
    print("Extracted Text: $extractedText"); // Log le texte extrait pour vérifier

    if (extractedText.isEmpty) {
      print("No text found on the current page to translate!");
      return;
    }

    try {
      // Traduire le texte dans la langue sélectionnée
      translatedText = await fetchTranslation(extractedText, selectedLanguage!);
      print("Translated Text: $translatedText"); // Log le texte traduit pour vérifier

      if (translatedText.isNotEmpty) {
        print("Reading translated text.");
        await _setLanguageForTts(selectedLanguage!);
        flutterTts.speak(translatedText);
      } else {
        print("Translation failed. No text to read.");
      }
    } catch (e) {
      print("Error during translation: $e");
    }
  }

  // Arrêter la lecture
  void onStopPressed() {
    flutterTts.stop();
  }

  // Configurer la langue pour le TTS
  Future<void> _setLanguageForTts(String language) async {
    flutterTts.stop();
    switch (language) {
      case "English UK":
        await flutterTts.setLanguage("en-GB");
        break;
      case "English US":
        await flutterTts.setLanguage("en-US");
        break;
      case "French":
        await flutterTts.setLanguage("fr-FR");
        break;
      case "Spanish":
        await flutterTts.setLanguage("es-ES");
        break;
      case "Arabic":
        await flutterTts.setLanguage("ar-SA");
        break;
      default:
        print("Unsupported language: $language");
    }
  }

  // API de traduction
  Future<String> fetchTranslation(String text, String selectedLanguage) async {
    String targetLang = selectedLanguage.substring(0,2);

     
    print(" heyyyy,$targetLang");
    final String apiUrl = 'https://sd3.savooria.com/translate';

    final Map<String, dynamic> body = {
      'text': text,
      'targetLang': targetLang,
    };


    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['translatedText'] ?? 'Translation not available';
    } else {
      return 'Failed to load translation';
    }
  }

  // Extraire le texte de la page actuelle du PDF
  void loadTextFromPdf() {
    if (downloadedPdfFile == null) {
      print("The PDF file has not been downloaded yet.");
      return;
    }

    try {
      final document = syncfusion.PdfDocument(inputBytes: downloadedPdfFile!.readAsBytesSync());
      extractedText = syncfusion.PdfTextExtractor(document).extractText(startPageIndex: currentPage.value - 1);
      document.dispose();
    } catch (e) {
      print("Error extracting text: $e");
    }
  }

  @override
  void onClose() {
    super.onClose();
    flutterTts.stop(); // Arrête toute lecture en cours
    animationController.dispose(); // Libère les ressources utilisées par l'animation
    pdfController?.dispose(); // Libère les ressources du PDF
    print("ListeningController resources disposed.");
  }
  /// Construire une option de langue
  Widget _buildLanguageOption(String label, String code) {
    return RadioListTile<String>(
      title: Text(label),
      value: code,
      groupValue: selectedLanguage,
      onChanged: (value) {

    selectedLanguage = value!;
       flutterTts.setLanguage(code);
        Get.back();
      },
    );
  }
  /// Afficher une boîte de dialogue pour la sélection de langue
  void showLanguageSelectionDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose language".tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption("english(Uk)" , "en-GB"),
              _buildLanguageOption("english(US) ", "en-US"),
              _buildLanguageOption("French", "fr-FR"),
              _buildLanguageOption("spanish", "es-ES"),
              _buildLanguageOption("arabic", "ar-SA"),
            ],
          ),
          actions: [
            TextButton(
              child: Text("OK".tr),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Cancel".tr),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

}
