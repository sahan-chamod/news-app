import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class NewsService {
  final String _apiKey =
      '7c2862b9d388450d9a80cb42dbbac494'; 
  final String _baseUrl = 'https://newsapi.org/v2/';

  // Fetch top headlines (default method)
  Future<List<Article>> fetchTopHeadlines() async {
    final url = Uri.parse('$_baseUrl/top-headlines?country=us&apiKey=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = (data['articles'] as List)
          .map((article) => Article.fromJson(article))
          .toList();
      return articles;
    } else {
      throw Exception('Failed to load articles');
    }
  }

  // Fetch articles by category
  Future<List<Article>> fetchArticlesByCategory(String category) async {
    final url = Uri.parse(
        '$_baseUrl/top-headlines?category=$category&country=us&apiKey=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = (data['articles'] as List)
          .map((article) => Article.fromJson(article))
          .toList();
      return articles;
    } else {
      throw Exception('Failed to load articles for category: $category');
    }
  }

  // Search news based on a query
  Future<List<Article>> searchNews(String query) async {
    final url = Uri.parse('$_baseUrl/everything?q=$query&apiKey=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = (data['articles'] as List)
          .map((article) => Article.fromJson(article))
          .toList();
      return articles;
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
