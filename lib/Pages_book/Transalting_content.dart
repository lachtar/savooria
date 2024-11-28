import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslatingContentPage extends StatefulWidget {
  final String extractedText;
  final String selectedLanguage;

  const TranslatingContentPage({
    Key? key,
    required this.extractedText,
    required this.selectedLanguage,
  }) : super(key: key);

  @override
  _TranslatingContentPageState createState() => _TranslatingContentPageState();
}

class _TranslatingContentPageState extends State<TranslatingContentPage> {
  late Future<String> translatedText;

  @override
  void initState() {
    super.initState();
    translatedText = fetchTranslation(widget.extractedText, widget.selectedLanguage);
  }

  String cleanExtractedText(String text) {
    return text
        .replaceAll(RegExp(r'^\s*$\n', multiLine: true), '') // Remove empty lines
        .replaceAll(RegExp(r'^\d+\.\s*', multiLine: true), '') // Remove numbered lists
        .replaceAll(RegExp(r'\. '), '.\n'); // Add a newline after each period
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
      appBar: AppBar(
        title: Text("Traduction".tr, style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFD4B79F),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<String>(
        future: translatedText,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final cleanedText = cleanExtractedText(snapshot.data!);
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Text(
                    cleanedText.isEmpty
                        ? "No extracted text available."
                        : cleanedText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Georgia',
                      color: Colors.black,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            );
          }
          return Center(child: Text("No data"));
        },
      ),
    );
  }
}
