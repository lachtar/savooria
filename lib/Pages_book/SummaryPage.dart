import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class SummaryPage extends StatefulWidget {
  final String pdfPath;

  const SummaryPage({Key? key, required this.pdfPath}) : super(key: key);

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  late Box summaryBox;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      // Définir un chemin personnalisé pour Hive
      final directory = Directory('${Directory.systemTemp.path}/hive_data');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      Hive.init(directory.path); // Initialise Hive dans le répertoire temporaire

      // Ouvrir ou créer la boîte Hive
      summaryBox = await Hive.openBox('summaryBox');
      final existingSummary = summaryBox.get('summary');
      if (existingSummary != null) {
        setState(() {
          _messages.add({
            "message": existingSummary,
            "isBot": true,
          });
          _isLoading = false;
        });
      } else {
        _fetchSummary(widget.pdfPath,"Summarize this File");
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "message": "Failed to initialize Hive: $e",
          "isBot": true,
        });
        _isLoading = false;
      });
    }
  }
  Future<void> _fetchSummary(String fileUrl, String question) async {
    try {
      // Préparer les données pour l'API summarize
      var requestBody = json.encode({
        "file_url": fileUrl,
        "question": question,
      });

      // Envoyer la requête POST à l'API summarize
      var summarizeResponse = await http.post(
        Uri.parse('https://sd2.savooria.com/summarize'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      // Vérifier la réponse de l'API
      if (summarizeResponse.statusCode == 200) {
        var responseData = json.decode(summarizeResponse.body);

        if (responseData.containsKey('summary')) {
          final summary = responseData['summary'];
          setState(() {
            _messages.add({
              "message": summary,
              "isBot": true,
            });
          });
        } else {
          setState(() {
            _messages.add({
              "message": "No summary found in the response.",
              "isBot": true,
            });
          });
        }
      } else {
        setState(() {
          _messages.add({
            "message": "Failed to fetch summary. Status: ${summarizeResponse.statusCode}",
            "isBot": true,
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "message": "An error occurred: $e",
          "isBot": true,
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    summaryBox.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Summary".tr,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD4B79F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: Color(0xFFD4B79F),
            ),
            const SizedBox(height: 16),
            Text(
              "No summary available.\nUpload a PDF to get started.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isBot = _messages[index]["isBot"] ?? false;
                if (isBot) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        _messages[index]["message"],
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}