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

  // Filter articles by date range
  void filterArticlesByDateRange(DateTime startDate, DateTime endDate) {
    try {
      _articles = _articles.where((article) {
        DateTime articleDate = DateTime.parse(article.publishedAt);
        return articleDate.isAfter(startDate) && articleDate.isBefore(endDate);
      }).toList();
      _clearErrorState();
    } catch (e) {
      _setErrorState("Failed to filter articles by date range. Error: $e");
      debugPrint("Error in filterArticlesByDateRange: $e");
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
