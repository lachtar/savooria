import 'package:flutter/material.dart';
import 'package:trrr/home/model/book.dart';
import '../../Pages_book/Pages_book.dart';

import 'package:get/get.dart';
import 'package:trrr/traduction/intl.dart';
class CategoryScreen extends StatefulWidget {
  final String category;
  final List<Book> books;

  const CategoryScreen({Key? key, required this.category, required this.books})
      : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool showUsername = true; // Set to true to display username by default
  final String username = "John Doe".tr; // Replace with actual username if needed
  final String time = " time : 3days ago".tr;
  bool showMessageInput = false; // To toggle message input visibility
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: TextStyle(
            color: Color(0xFF7CA8C1), // Blue color similar to the logo
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Icône de flèche retour
          onPressed: () {
            Navigator.of(context).pop(); // Retourne à l'écran précédent
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_book), // Icône personnalisée
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Ouvre le Drawer
              },
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Color(0xFF7CA8C1)),
        elevation: 0,
      ),
      drawer: _buildSlidingDrawer(context), // Drawer standard
      // Drawer on the right side
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              "Popular Books".tr,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20.0),
           // Expanded(
              //child: _makeBookGrid(BookList.newArrivalBooks, context),
            //),//
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              print("Add Books button pressed".tr);
            },
            child: const Icon(Icons.book),
            backgroundColor: Color(0xFF7CA8C1),
            tooltip: 'Add Books'.tr,
          ),
          const SizedBox(width: 16.0),
        ],
      ),
    );
  }



  Widget _buildSlidingDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: Color(0xFFD4B79F), // Updated blue color similar to the logo
            height: 150,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFD4B79F), // Updated blue color for consistency
              ),
              child: Row(
                children: [
                  Icon(Icons.forum, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Forum',
                    style: TextStyle(
                      color: Colors.black, // Text color set to white
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 10),
              Text(
                username,

                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),

            ],

          ),
          Text(
            time,

            style: TextStyle(
              color: Colors.black54,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          Divider(),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 10),
              Text(
                username,

                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),

            ],

          ),
          Text(
            time,

            style: TextStyle(
              color: Colors.black54,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.message, color: Colors.black),
            title: Text(
              'Discussions'.tr,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),

            onTap: () {
              setState(() {
                showMessageInput = !showMessageInput; // Toggle message input visibility
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
                      // Handle message submission here
                      print("Message sent: ${messageController.text}");
                      messageController.clear(); // Clear the text field after sending
                    },
                    child: Text(
                      "Send".tr,
                      style: TextStyle(
                        color: Color(0xFFD4B79F),  // Changer la couleur du texte
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

  Widget _makeBookEl(Book book, BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Navigating to PDF at path: ${book.pdfPath}".tr);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewer3D(pdfPath: book.pdfPath),
          ),
        );
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                book.image,
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

