import 'dart:convert';
import 'package:http/http.dart' as http;
import 'article.dart';

class NewsService {
  static const String _apiKey = 'f22f96bace9f457cb2f3da2bc9e5289a'; 
  static const String _baseUrl = 'https://newsapi.org/v2';

  Future<List<Article>> fetchNews({String category = 'general'}) async {
    final url =
        '$_baseUrl/top-headlines?country=us&category=$category&apiKey=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'ok') {
        final List articlesJson = jsonData['articles'];
        return articlesJson.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news: ${jsonData['message']}');
      }
    } else {
      throw Exception('Failed to fetch news: ${response.statusCode}');
    }
  }
}
