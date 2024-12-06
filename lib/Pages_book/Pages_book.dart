import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '/Pages_book/PageBook_serviceTrans.dart';
import '/Pages_book/SummaryPage.dart';
import '../home/data/ListeningController.dart';
import '../home/model/book.dart';
import 'AuthController.dart';
import 'ChattingPage.dart'; // Import the ChattingPage
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

import 'ChattingPage2.dart';
class PdfViewer3D extends StatefulWidget {
  final String pdfPath;



  const PdfViewer3D({Key? key, required this.pdfPath}) : super(key: key);

  @override
  _PdfViewer3DState createState() => _PdfViewer3DState();
}

class _PdfViewer3DState extends State<PdfViewer3D> with SingleTickerProviderStateMixin {
  final List<String> _options = ['Summary'.tr, 'Translating'.tr, 'Chatting'.tr,'upload PDF '.tr];

  late ListeningController controller;
  List<Book> books = [];
  int? currentCategoryId;
  var bookTitle="";
  var pdfpath="";

  final arguments = Get.arguments;
  final title = Get.arguments[1];
  // Passer le chemin du PDF au contrôleur


  @override
  void initState() {
    super.initState();


 controller=Get.put(ListeningController(pdfPath: widget.pdfPath));


  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  void _showOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: _options.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.check_circle),
              iconColor: Color(0xFFD4B79F),
              title: Text(_options[index]),
              onTap: () {
                // Check if "Chatting" option is selected
                if (_options[index] == 'Chatting'.tr) {

                  Navigator.pop(context);
                  Future.delayed(Duration(milliseconds: 200), () {
                    Get.to(()=> ChattingPage2(),arguments: [title,widget.pdfPath]);
                  });
                } else if (_options[index] == 'Translating'.tr) {

                  Navigator.pop(context);

                  Get.to(()=>Translating(pdfPath:widget.pdfPath ));
                } else if (_options[index] == 'Summary'.tr) {
                  Navigator.pop(context);
                  Future.delayed(Duration(milliseconds: 200), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SummaryPage(pdfPath: widget.pdfPath)),
                    );
                  });
                }
                else {
                  // Close the modal for other options
                  Navigator.pop(context);
                  _uploadPdf();
                }
              },
            );
          },
        );
      },
    );
  }
  Future<void> _uploadPdf() async {
    try {
      print("Début de la méthode _uploadPdf");

      // Vérification si le fichier PDF téléchargé est null
      if (controller.downloadedPdfFile == null) {
        print("Le fichier PDF téléchargé est null");
        Get.snackbar(
          "Erreur",
          "Le fichier PDF n'a pas été téléchargé.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Récupération des arguments et validation
      final arguments = Get.arguments;
      if (arguments == null || arguments.length < 2) {
        print("Les arguments sont invalides ou manquants");
        Get.snackbar(
          "Erreur",
          "Les informations nécessaires (catégorie et titre) sont manquantes.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final categoryId = arguments[0];
      final title = arguments[1];
      print("Catégorie ID : $categoryId, Titre : $title");

      final url = 'https://savooria.com/json/category/$categoryId/upload';

      // Récupération du token de l'utilisateur depuis AuthController
      final token = AuthController.instance.token.value;
      if (token.isEmpty) {
        print("Token d'authentification manquant");
        Get.snackbar(
          "Erreur",
          "Vous devez être authentifié pour effectuer cette opération.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Création des données du formulaire
      final formData = dio.FormData.fromMap({
        'book_name': title,
        'file': await dio.MultipartFile.fromFile(
          controller.downloadedPdfFile!.path,
          filename: 'book.pdf',
        ),
      });

      // Configuration du client Dio avec les headers nécessaires
      dio.Dio dioClient = dio.Dio();
      dioClient.options.headers = {
        'Authorization': 'Bearer $token',
      };

      print("Envoi de la requête POST vers $url");


      final response = await dioClient.post(url, data: formData);

      print("Réponse reçue : ${response.statusCode}");
      if (response.statusCode == 201) {
        final responseData = response.data;
        final message = responseData['message'] ?? 'Téléchargement réussi!';
        print("Succès : $message");
        Get.snackbar(
          "Succès",
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF7CA8C1),
          colorText: Colors.white,
        );
      } else {
        final errorMessage = response.data['message'] ?? "Une erreur est survenue (${response.statusCode})";
        print("Erreur lors de la requête : $errorMessage");
        Get.snackbar(
          "Erreur",
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception : $e");
      Get.snackbar(
        "Erreur",
        "Une erreur s'est produite : $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }




  void _showLanguageSelectionDialog() {
    String selectedLanguage = ""; // To track the selected language

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Choose Language".tr),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text("English(UK)".tr),
                    value: "English",
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                      print("English selected");
                    },
                  ),
                  RadioListTile<String>(
                    title: Text("English(US)".tr),
                    value: "English US",
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                      print("English selected");
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
                      print("French selected");
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
                      print("Spanish selected");
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
                      print("Arabic selected");
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(
                    "Cancel".tr,
                    style: TextStyle(
                      color: Color(0xFFD4B79F), // Couleur du texte
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    "OK".tr,
                    style: TextStyle(
                      color: Color(0xFFD4B79F), // Couleur du texte
                    ),
                  ),
                  onPressed: () {
                    // Handle the selected language here, if needed
                    Navigator.pop(context);
                    print("Selected language: $selectedLanguage");
                  },
                ),
              ],
            );
          },
        );
      },
    );
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
                bottom: screenHeight * 0.1, // Adjusting position based on screen size
                left: screenWidth * 0.8,
                right: 0,
                child: Center(
                  child: FloatingActionButton(
                    onPressed: _showOptions,
                    backgroundColor: Color(0xFFD4B79F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.add),
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
