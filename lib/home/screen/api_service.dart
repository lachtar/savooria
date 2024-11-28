import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/book.dart';

class ApiService {
  static const String _baseUrl = 'https://savooria.com/json/books';

  // Fetch books from the API
  static Future<List<Book>> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse books
        List<Book> books = (data['books'] as List)
            .map((bookJson) => Book.fromJson(bookJson))
            .toList();

        return books;
      } else {
        throw Exception("Failed to load books");
      }
    } catch (e) {
      throw Exception("Error fetching books: $e");
    }
  }
}
