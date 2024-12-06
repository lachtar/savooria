import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/home/model/book.dart';
import '../../../Pages_book/PageBook_serviceList.dart';
import '../../../Pages_book/PageBook_serviceTrans.dart';

import '../api_service.dart';


class Translating2 extends StatefulWidget {
  @override
  _SummarizeState createState() => _SummarizeState();
}

class _SummarizeState extends State<Translating2> {
  // Variable pour basculer la visibilité de la recherche
  List<Book> filteredBooks = [];
  bool isLoading = true;
  late Future<List<dynamic>> categoriesFuture;
  late Future<List<dynamic>> booksFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = fetchCategories();
    booksFuture = fetchBooks();
  }

  Future<List<dynamic>> fetchCategories() async {
    final url = Uri.parse(
        'https://savooria.com/json/categories');
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
  void _searchBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        fetchBooks();
      } else {
        filteredBooks = filteredBooks
            .where((book) => book.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
  // Méthode pour afficher la barre de recherche
  Widget _makeSearchBoxEl() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),

    );
  }

  // Méthode pour afficher un élément de livre
  Widget _makeBookEl(Book book, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Préfixer l'URL de base à pdfPath
        String fullPdfPath = "https://savooria.com/" + book.pdfPath;
        print("Navigating to PDF at path: $fullPdfPath");
        /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  ListeningViewer(pdfPath: fullPdfPath), // Passer l'URL complète du PDF
          ),
        );*/
        Get.to(()=> Translating(pdfPath: fullPdfPath,) , arguments:  fullPdfPath);
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                "https://savooria.com/images/book_images/large/" + book.image,
                height: 120.0,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              book.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher la grille des livres
  Widget _makeBookGrid(List<Book> books, BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _makeBookEl(book, context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15.0),
          ),

        ),
        iconTheme: const IconThemeData(color: Color(0xFFD4B79F)),
        elevation: 0,
      ),
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
                          // Padding interne
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // Couleur de fond de la bannière
                            borderRadius: BorderRadius.circular(12.0),
                            // Coins arrondis
                            border: Border.all(
                                color: Colors.white, width: 0.5), // Bordure
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
                          if (bookSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (bookSnapshot.hasError) {
                            return Text('Error: ${bookSnapshot.error}');
                          } else if (!bookSnapshot.hasData ||
                              bookSnapshot.data!.isEmpty) {
                            return const Text('No books found.');
                          } else {
                            final books = bookSnapshot.data!
                                .where((book) =>
                            book['category_id'] == category['id'])
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
                                      String fullPdfPath =
                                          "https://savooria.com/" +
                                              book.pdfPath;
                                      print(
                                          "Navigating to PDF at path: $fullPdfPath");
                                      Get.to(() =>
                                          Translating(pdfPath: fullPdfPath,) , arguments:  fullPdfPath);
                                    },
                                    child: Container(
                                      width: 140,
                                      margin:
                                      const EdgeInsets.only(right: 10.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(10.0),
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
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                            const BorderRadius.only(
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.circular(10.0),
                                            ),
                                            child: Image.network(
                                              'https://savooria.com/images/book_images/large/${book
                                                  .image}',
                                              width: 140,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
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

