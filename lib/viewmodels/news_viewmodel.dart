import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../services/news_service.dart';
import '../dhhelper/db.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsService _newsService = NewsService();
  final DBHelper _dbHelper = DBHelper();

  List<Article> _articles = [];
  List<Article> get articles => _articles;

  List<Article> _bookmarkedArticles = [];
  List<Article> get bookmarkedArticles => _bookmarkedArticles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  // Fetch articles by category
  Future<void> fetchArticlesByCategory(String category) async {
    _setLoadingState(true);
    try {
      _articles = await _newsService.fetchArticlesByCategory(category);
      if (_articles.isEmpty) {
        _setErrorState("No articles found in the '$category' category.");
      } else {
        _clearErrorState();
      }
    } catch (e) {
      _setErrorState("Failed to fetch articles for '$category'. Error: $e");
      debugPrint("Error in fetchArticlesByCategory: $e");
    }
    _setLoadingState(false);
  }

  // Fetch top headlines
  Future<void> fetchTopHeadlines() async {
    _setLoadingState(true);
    try {
      _articles = await _newsService.fetchTopHeadlines();
      if (_articles.isEmpty) {
        _setErrorState("No top headlines found.");
      } else {
        _clearErrorState();
      }
    } catch (e) {
      _setErrorState("Failed to load top headlines. Error: $e");
      debugPrint("Error in fetchTopHeadlines: $e");
    }
    _setLoadingState(false);
  }

  // Search news
  Future<void> searchNews(String query) async {
    _setLoadingState(true);
    try {
      _articles = await _newsService.searchNews(query);
      if (_articles.isEmpty) {
        _setErrorState("No articles found for the search query '$query'.");
      } else {
        _clearErrorState();
      }
    } catch (e) {
      _setErrorState("Failed to load search results. Error: $e");
      debugPrint("Error in searchNews: $e");
    }
    _setLoadingState(false);
  }

  // Fetch bookmarked articles
  Future<void> fetchBookmarks() async {
    try {
      final data = await _dbHelper.fetchBookmarks();
      _bookmarkedArticles = data.map((e) => Article.fromMap(e)).toList();
      _clearErrorState();
    } catch (e) {
      _setErrorState("Failed to fetch bookmarks. Error: $e");
      debugPrint("Error in fetchBookmarks: $e");
    }
    notifyListeners();
  }

  // Add article to bookmarks
  Future<void> addBookmark(Article article) async {
    try {
      await _dbHelper.insertBookmark(article.toMap());
      _bookmarkedArticles.add(article);
      _clearErrorState();
    } catch (e) {
      _setErrorState("Failed to add bookmark. Error: $e");
      debugPrint("Error in addBookmark: $e");
    }
    notifyListeners();
  }

  // Remove article from bookmarks
  Future<void> removeBookmark(String title) async {
    try {
      await _dbHelper.deleteBookmark(title);
      _bookmarkedArticles.removeWhere((article) => article.title == title);
      _clearErrorState();
    } catch (e) {
      _setErrorState("Failed to remove bookmark. Error: $e");
      debugPrint("Error in removeBookmark: $e");
    }
    notifyListeners();
  }

  // Check if an article is bookmarked
  bool isBookmarked(String title) {
    return _bookmarkedArticles.any((article) => article.title == title);
  }

  Future<void> filterArticlesByDateRange(
      DateTime startDate, DateTime endDate) async {
    _setLoadingState(true);

    try {
      // Format dates to the required format (YYYY-MM-DD)
      final String formattedStartDate =
          startDate.toIso8601String().substring(0, 10);
      final String formattedEndDate =
          endDate.toIso8601String().substring(0, 10);

      // Construct the NewsAPI URL
      final String apiKey = '7c2862b9d388450d9a80cb42dbbac494';

      final String url =
          "https://newsapi.org/v2/everything?q=*&from=$formattedStartDate&to=$formattedEndDate&apiKey=$apiKey";

      // Perform the API request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'ok' &&
            jsonResponse['articles'] != null) {
          // Convert articles into a list
          final List<dynamic> articles = jsonResponse['articles'];
          _articles = articles.map((e) => Article.fromMap(e)).toList();

          // Check if no articles were found
          if (_articles.isEmpty) {
            _setErrorState("No articles found within the selected date range.");
          } else {
            _clearErrorState();
          }
        } else {
          _setErrorState(
              "Failed to retrieve articles. Error: ${jsonResponse['message'] ?? 'Unknown error'}");
        }
      } else {
        _setErrorState(
            "HTTP Error: ${response.statusCode}. Failed to fetch articles.");
      }
    } catch (e) {
      _setErrorState("Failed to filter articles by date range. Error: $e");
      debugPrint("Error in filterArticlesByDateRange: $e");
    }

    _setLoadingState(false);
  }

  // Filter articles by language
  void filterArticlesByLanguage(String language) {
    try {
      _articles = _articles.where((article) {
        return article.language ==
            language; // Assuming Article has a `language` field.
      }).toList();
      _clearErrorState();
    } catch (e) {
      _setErrorState("Failed to filter articles by language. Error: $e");
      debugPrint("Error in filterArticlesByLanguage: $e");
    }
    notifyListeners();
  }

  // Private helper methods
  void _setLoadingState(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorState(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearErrorState() {
    _error = '';
    notifyListeners();
  }
}
