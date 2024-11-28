import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChattingPage2 extends StatefulWidget {
  @override
  _ChattingPageState createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage2> {
  final TextEditingController _controller = TextEditingController();
  late String bookTitle;
  late String fileeepath;

  final List<Map<String, dynamic>> _messages = [
    {"message": "Hello, how can I help you?", "isBot": true},
  ];
  bool isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    fileeepath = args != null && args.length > 1 ? args[1] : '';
    bookTitle = args != null && args.length > 0 ? args[0] : 'Unknown Book';

    print("Fulllll PDF Path: $fileeepath");
    print("Book Title: $bookTitle");
  }

  Future<void> _sendMessage(String text, String fileeepath) async {
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({"message": text, "isBot": false});
        _controller.clear();
        isLoading = true; // Start loading
      });

      print("Navigating to PDF at path: $fileeepath");

      try {
        final response = await http.post(
          Uri.parse("https://sd2.savooria.com/ask"),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "question": text,
            "file_url": fileeepath,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String botResponse = data['answer'] ?? "I couldn't process your request.";
          print("Response Body: ${response.body}");


          setState(() {
            _messages.add({"message": botResponse, "isBot": true});
          });
        } else {
          setState(() {
            _messages.add({
              "message": "An error occurred. Please try again later.".tr,
              "isBot": true,
            });
          });
        }
      } catch (error) {
        print("Error during API call: $error");
        setState(() {
          _messages.add({
            "message": "Failed to connect to the server. Please check your connection.".tr,
            "isBot": true,
          });
        });
      } finally {
        setState(() {
          isLoading = false; // Stop loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chatbot".tr,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD4B79F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isBot = _messages[index]["isBot"];
                return Align(
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBot ? Colors.grey[300] : const Color(0xFFD4B79F),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isBot ? const Radius.circular(0) : const Radius.circular(12),
                        bottomRight: isBot ? const Radius.circular(12) : const Radius.circular(0),
                      ),
                    ),
                    child: Text(
                      _messages[index]["message"],
                      style: TextStyle(
                        color: isBot ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading) // Show loader when loading
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message".tr,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFD4B79F)),
                  onPressed: () => _sendMessage(_controller.text, fileeepath),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
