import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '/home/model/book.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'AuthController.dart';
import 'PageBook_serviceList.dart';

class CategoryPage extends StatefulWidget {
  final int sectionId;
  final String sectionName;

  const CategoryPage({required this.sectionId, required this.sectionName});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<dynamic>> categoriesFuture;
  late Future<List<dynamic>> booksFuture;
  List<Book> books = [];
  bool showUsername = true;

  bool showMessageInput = false;
  final TextEditingController messageController = TextEditingController();
  int? currentCategoryId;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    categoriesFuture = fetchCategories(widget.sectionId);
    booksFuture = fetchBooks();
  }

  Future<List<dynamic>> fetchCategories(int sectionId) async {
    final url = Uri.parse(
        'https://savooria.com/json/categories-by-section/$sectionId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['categories'] ?? [];
    } else {
      throw Exception('Failed to load categories');
    }
  }
  Future<List<dynamic>> fetchMessages(int categoryId) async {
    final url = Uri.parse('https://savooria.com/json/forum/$categoryId/messages');
    final String token = Get.find<AuthController>().token.value;

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['messages'] ?? [];
    } else {
      throw Exception('Failed to load messages');
    }
  }
  Future<void> sendMessage(int categoryId, String messageContent) async {
    final url = Uri.parse('https://savooria.com/json/category/$categoryId/message');

    // Récupérer le token depuis AuthController
    final String token = Get.find<AuthController>().token.value;

    // Afficher le Bearer Token dans la console
    print('Bearer Token: $token');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Ajout du token dans les headers
      },
      body: jsonEncode({
        'content': messageContent,
      }),
    );

    if (response.statusCode == 200) {
      // Message envoyé avec succès
      print('Message sent successfully!');
    } else {
      // Échec de l'envoi du message
      print('Failed to send message: ${response.body}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
    title: Text(
    widget.sectionName,
    style: const TextStyle(
    fontFamily: 'Georgia'),
    ),
        iconTheme: const IconThemeData(color: Color(0xFFD4B79F)),
        elevation: 0,
      ),
      drawer: _buildSlidingDrawer(context),
      drawerEnableOpenDragGesture: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: No Messages Found');
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
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0), // Padding interne
                  decoration: BoxDecoration(
                  color: Colors.white, // Couleur de fond de la bannière
                  borderRadius: BorderRadius.circular(12.0), // Coins arrondis
                  border: Border.all(color: Colors.white, width: 0.5), // Bordure
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
                  IconButton(
                  icon: const Icon(Icons.forum, color: Color(0xFFD4B79F)),
    onPressed: () {
      setState(() {
        currentCategoryId = category['id']; // Mise à jour ici
      });
      _scaffoldKey.currentState?.openDrawer();
    },
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
                                          "https://savooria.com/" + book.pdfPath;
                                      print(
                                          "Navigating to PDF at path: $fullPdfPath");
                                      Get.to(() => ListeningViewer(
                                          pdfPath: fullPdfPath));
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
                                              'https://savooria.com/images/book_images/large/${book.image}',
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

  Widget _buildSlidingDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: Color(0xFFD4B79F), // Couleur mise à jour similaire au logo
            height: 150,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFD4B79F), // Consistance dans la couleur
              ),
              child: Row(
                children: [
                  Icon(Icons.forum, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Forum',
                    style: TextStyle(
                      color: Colors.black, // Couleur du texte mise à jour
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Première section avec les messages
          FutureBuilder<List<dynamic>>(
            future: fetchMessages(currentCategoryId ?? 0), // Si `currentCategoryId` est null, on met 0
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('No messages found.');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No messages found.');
              } else {
                final messages = snapshot.data!;
                return Expanded(
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final createdAt = DateTime.parse(message['created_at']);
                      final formattedTime = '${createdAt.hour}:${createdAt.minute}'; // Format de l'heure

                      // Crée chaque message dans un Divider avec un Row à côté de l'icône de la personne
                      return Column(
                        children: [
                          Divider(), // Diviseur avant chaque message
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Icon(Icons.person, color: Colors.black),
                              ),
                              const SizedBox(width: 10),
                              Expanded( // Pour occuper l'espace restant
                                child: Text(
                                  message['content'],
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }
            },
          ),

          Divider(), // Divider avant la section Discussions

          ListTile(
            leading: Icon(Icons.message, color: Colors.black),
            title: Text(
              'Discussions'.tr,
              style: TextStyle(
                color: Color(0xFFD4B79F),
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              setState(() {
                showMessageInput = !showMessageInput; // Toggle visibilité de l'input de message
              });
            },
          ),

          if (showMessageInput)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Write a message...".tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (currentCategoryId != null && messageController.text.isNotEmpty) {
                        sendMessage(currentCategoryId!, messageController.text);
                        messageController.clear();
                      }
                    },
                    child: Text(
                      "Send".tr,
                      style: TextStyle(
                        color: Color(0xFFD4B79F), // Changer la couleur du texte
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Divider(),
        ],
      ),
    );
  }


}

