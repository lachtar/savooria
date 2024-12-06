import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../Pages_book/PageBook_serviceIa.dart';
import '../../model/book.dart';

class ChatbotIa extends StatefulWidget {
  @override
  _ChatbotIaState createState() => _ChatbotIaState();
}

class _ChatbotIaState extends State<ChatbotIa> {
  final TextEditingController messageController = TextEditingController();
  late Future<List<dynamic>> categoriesFuture;
  late Future<List<dynamic>> booksFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = fetchCategories();
    booksFuture = fetchBooks();
  }

  Future<List<dynamic>> fetchCategories() async {
    final url = Uri.parse('https://savooria.com/json/categories');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['categories'] ?? [];
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<dynamic>> fetchBooks() async {
    final url = Uri.parse('https://savooria.com/json/books');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['books'] ?? [];
    } else {
      throw Exception('Failed to load books');
    }
  }

  // Fonction pour sélectionner un fichier
  Future<void> _uploadFile() async {
    // Ouvrir le sélecteur de fichiers
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // Récupérer le fichier sélectionné
      String filePath = result.files.single.path!;
      String fileName = result.files.single.name;

      print("File selected: $filePath");


      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://sd2.savooria.com/upload'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      var response = await request.send();
      // Lire la réponse du serveur
      String responseBody = await response.stream.bytesToString();
      print(responseBody);

      if (response.statusCode == 200) {

        print('File uploaded successfully!');

      } else {
        print('File upload failed');
      }
    } else {
      print('No file selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
        iconTheme: IconThemeData(color: Color(0xFFD4B79F)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _uploadFile,  // Appel de la fonction d'upload lors du clic sur le bouton
          ),
        ],
      ),
      drawerEnableOpenDragGesture: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No categories found.');
            } else {
              final categories = snapshot.data!;
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, categoryIndex) {
                  final category = categories[categoryIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 15.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.white, width: 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category['category_name'],
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      FutureBuilder<List<dynamic>>(
                        future: booksFuture,
                        builder: (context, bookSnapshot) {
                          if (bookSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (bookSnapshot.hasError) {
                            return Text('Error: ${bookSnapshot.error}');
                          } else if (!bookSnapshot.hasData || bookSnapshot.data!.isEmpty) {
                            return const Text('No books found.');
                          } else {
                            final books = bookSnapshot.data!
                                .where((book) => book['category_id'] == category['id'])
                                .map((bookData) => Book.fromJson(bookData))
                                .toList();
                            // Vérification si cette catégorie a des livres
                            if (books.isEmpty) {
                              return const SizedBox(); // Rien à afficher
                            }


                            return SizedBox(
                              height: 230,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: books.length,
                                itemBuilder: (context, index) {
                                  final book = books[index];
                                  return GestureDetector(
                                    onTap: () {
                                      String fullPdfPath = "https://savooria.com/" + book.pdfPath;
                                      print("Navigating to PDF at path: $fullPdfPath");
                                      Get.to(() => PdfViewer3D(pdfPath: fullPdfPath), arguments: [book.title, book.pdfPath]);
                                    },
                                    child: Container(
                                      width: 140,
                                      margin: const EdgeInsets.only(right: 10.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.circular(10.0),
                                            ),
                                            child: Image.network(
                                              'https://savooria.com/images/book_images/large/${book.image}',
                                              width: 140,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Text(
                                              book.title,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
