import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/book.dart';

class ApiService {
  static const _baseUrl = 'https://api.bukuacak.shabsolute.tech/api/v1/book';

  Future<List<Book>> fetchBooks(String category) async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat buku (${response.statusCode}).');
    }

    final body = jsonDecode(response.body);
    final items = body is Map<String, dynamic> ? body['books'] : null;

    if (items is! List) {
      throw Exception('Format data buku tidak sesuai.');
    }

    final books = items
        .whereType<Map<String, dynamic>>()
        .map(Book.fromApi)
        .where((book) => book.title.isNotEmpty)
        .toList();

    if (category.toLowerCase() == 'all') return books;

    final keyword = category.toLowerCase();
    return books.where((book) => book.matchesCategory(keyword)).toList();
  }
}
