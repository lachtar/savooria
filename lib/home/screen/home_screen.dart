import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trrr/Pages_book/PageBook_serviceList.dart';
import 'package:trrr/home/model/book.dart';
import 'package:trrr/home/screen/Services/Listening.dart';
import 'package:trrr/home/screen/Services/Summarize.dart';
import 'package:trrr/home/screen/Services/Translating.dart';
import '../../Pages_book/categorie_By section_Books.dart';
import '../data/ListeningController.dart';
import 'CategoryScreen.dart';
import 'package:get/get.dart';
import 'package:trrr/traduction/intl.dart';
import 'api_service.dart';
import 'detail_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'custom_card_widget.dart';
import 'button_cards.dart';
import 'package:trrr/Pages_book/Pages_book.dart';
import 'MyProfile.dart';
import 'package:trrr/home/screen/Services/Chatbot IA.dart';

/// Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color _accentColor = const Color(0xFF272727);
  bool _isSearchVisible = false; // Contrôle la visibilité de la barre de recherche
  int _selectedIndex = 0; // To track the selected tab
  late Future<List<Book>> _booksFuture;
  List<Map<String, dynamic>> sections = [];
  late ListeningController controller;
  List<Book> allBooks = []; // Contiendra tous les livres (original).
  List<Book> filteredBooks = []; // Contiendra les livres filtrés.



  @override
  void initState() {
    super.initState();
    _booksFuture = ApiService.fetchBooks();
    _booksFuture.then((books) {
      setState(() {
        allBooks = books; // Stocker tous les livres.
        filteredBooks = books; // Par défaut, les deux listes sont identiques.
      });
    });// Initialisation des données
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to MyProfile page if "My Page" icon is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditProfilePage()),
      );
    } else {
      // Otherwise, set the selected index to the tapped tab index
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  // Fonction pour récupérer les données de l'API
  Future<List<Map<String, dynamic>>> fetchSections() async {
    final response = await http.get(Uri.parse('https://savooria.com/json/sections'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['sections']);
    } else {
      throw Exception('Failed to load sections');
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double aspectRatio = screenWidth / screenHeight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Image.asset(
            'assets/images/logoo.png',
            width: 24,
            height: 24,
          ),
        ),
        title: Text(
          "Welcome Back".tr,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
            color: Colors.black, // Couleur du titre (changez si besoin)
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 23.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearchVisible = !_isSearchVisible;

                    });
                  },
                  child: const Icon(Icons.search, color: Colors.black45),
                ),


              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.05,
            ),
            child: Column(
              children: [
                // Affichage de la barre de recherche conditionnellement
                Visibility(
                  visible: _isSearchVisible,
                  child: _makeSearchBoxEl(),
                ),
                const SizedBox(height: 25.0),

                // FutureBuilder pour récupérer les sections depuis l'API
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchSections(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      sections = snapshot.data!;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: sections.map((section) {
                            // Définir une couleur différente pour chaque type de carte
                            int cardType = (section['id'] % 3) + 1; // Alterne les types de cartes entre 1, 2 et 3

                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0), // Ajoute un espace entre chaque carte
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CategoryPage(
                                        sectionId: section['id'],
                                        sectionName: section['name'],
                                      ),
                                    ),
                                  );
                                },
                                child: SmallCardWidget(
                                  title: section['name'], // Nom de la section
                                  // Sous-titre par défaut ou traduction
                                  cardType: cardType,

                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );

                    } else {
                      return Text('No data available');
                    }
                  },
                ),
                const SizedBox(height: 20.0),

                // Section des services
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Our Services'.tr,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Centrer les ButtonCards
                        children: [
                          ButtonCard(
                            title: 'Chatbot IA'.tr,
                            imagePath: 'assets/images/chatbot.png',
                            onTap: () {
                              // Redirection vers ChatbotIa.dart
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChatbotIa()),
                              );
                            },
                          ),
                          SizedBox(width: 30),
                          ButtonCard(
                            title: 'Listening'.tr,
                            imagePath: 'assets/images/listening2.png',
                            onTap: () {
                              // Redirection vers Listening
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Listening()),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Centrer les ButtonCards
                        children: [
                          ButtonCard(
                            title: 'Translating'.tr,
                            imagePath: 'assets/images/translating.png',
                            onTap: () {
                              // Redirection vers Translating
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Translating2()),
                              );
                            },
                          ),
                          SizedBox(width: 30),
                          ButtonCard(
                            title: 'Summarizing'.tr,
                            imagePath: 'assets/images/summ.png',
                            onTap: () {
                              // Redirection vers Summarize
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Summarize()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),

                // Section des livres populaires avec FutureBuilder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular Books".tr,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),

                // Utilisation de FutureBuilder pour charger les livres
                FutureBuilder<List<Book>>(
                  future: _booksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'.tr));
                    } else if (snapshot.hasData) {
                      // Utilisez filteredBooks au lieu de snapshot.data.
                      return _makeBookSlider(filteredBooks, context);
                    } else {
                      return const Center(child: Text('No books available.'));
                    }
                  },
                ),

              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: _accentColor,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Iconsax.book),
            activeIcon: Icon(Iconsax.book, color: _accentColor),
            label: 'Book'.tr,
            tooltip: "This is a Book Page".tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Iconsax.profile_circle),
            activeIcon: Icon(Iconsax.personalcard, color: _accentColor),
            label: 'Profile'.tr,
            tooltip: "This is a School Page".tr,
          ),
        ],
      ),
    );
  }

  Widget _makeBookSlider(List<Book> books, BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Direction horizontale
      child: Row(
        children: books.map((book) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0), // Espacement entre les livres
            child: _makeBookEl(book, context),
          );
        }).toList(),
      ),
    );
  }

  Widget _makeBookEl(Book book, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Préfixer l'URL de base à pdfPath
        String fullPdfPath = "https://savooria.com/" + book.pdfPath;
        print("Navigating to PDF at path: $fullPdfPath");
        Get.to(() => PdfViewer3D(pdfPath: fullPdfPath) , arguments: [book.categoryId , book.title]);
      },
      child: SizedBox(
        width: 100.0, // Largeur du conteneur pour chaque livre
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligner les éléments à gauche
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0), // Bordures arrondies
              child: Image.network(
                "https://savooria.com/images/book_images/large/" + book.image,
                height: 140.0, // Ajuster la hauteur de l'image
                fit: BoxFit.cover, // Ajuster l'image à l'espace disponible
              ),
            ),
            const SizedBox(height: 10.0), // Espacement entre l'image et le titre
            Text(
              book.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600, // Poids de la police
                fontSize: 14.0, // Taille de la police
              ),
              overflow: TextOverflow.ellipsis, // Texte tronqué si trop long
              maxLines: 1, // Limiter à une seule ligne
            ),
          ],
        ),
      ),
    );
  }

  void searchBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBooks = allBooks; // Rétablir tous les livres si la recherche est vide.
      } else {
        filteredBooks = allBooks
            .where((book) => book.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }





  Widget _makeSearchBoxEl() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        onChanged: searchBooks, // Appelle la méthode searchBooks sur chaque changement
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          prefixIcon: const Icon(Icons.search),
          hintText: "Search here...".tr,
          hintStyle: const TextStyle(
            fontFamily: 'Georgia',
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
          ),
        ),
      ),
    );
  }



  Widget _buildCategoryCard(String title, IconData icon, Color color1, Color color2) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

