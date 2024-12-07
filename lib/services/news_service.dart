import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class NewsService {
  final String _apiKey = '7c2862b9d388450d9a80cb42dbbac494';
  final String _baseUrl = 'https://newsapi.org/v2/';

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

  Future<List<Article>> fetchArticlesByDateRange(
      DateTime startDate, DateTime endDate) async {
    final String formattedStartDate =
        startDate.toIso8601String().substring(0, 10);
    final String formattedEndDate = endDate.toIso8601String().substring(0, 10);

    final String url =
        '$_baseUrl?q=*&from=$formattedStartDate&to=$formattedEndDate&apiKey=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'ok' &&
            jsonResponse['articles'] != null) {
          final List<dynamic> articles = jsonResponse['articles'];
          return articles.map((e) => Article.fromMap(e)).toList();
        } else {
          throw Exception(
              "Failed to retrieve articles: ${jsonResponse['message'] ?? 'Unknown error'}");
        }
      } else {
        throw Exception(
            "HTTP Error: ${response.statusCode}. Failed to fetch articles.");
      }
    } catch (e) {
      throw Exception("Error fetching articles: $e");
    }
  }
}
