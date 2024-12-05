import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/news_viewmodel.dart';
import 'article_detail_view.dart';
import 'Bookmarks.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  final List<String> categories = [
    'technology',
    'politics',
    'science',
    'health'
  ];
  Timer? _debounce;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        String category = categories[_tabController.index];
        Provider.of<NewsViewModel>(context, listen: false)
            .fetchArticlesByCategory(category);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsViewModel>(context, listen: false)
          .fetchArticlesByCategory(categories[0]);
      Provider.of<NewsViewModel>(context, listen: false).fetchBookmarks();
    });

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        Provider.of<NewsViewModel>(context, listen: false)
            .searchNews(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedStartDate != null) {
      final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: _endDate ?? DateTime.now(),
        firstDate: pickedStartDate,
        lastDate: DateTime.now(),
      );

      if (pickedEndDate != null) {
        setState(() {
          _startDate = pickedStartDate;
          _endDate = pickedEndDate;
        });

        // Apply the date filter
        Provider.of<NewsViewModel>(context, listen: false)
            .filterArticlesByDateRange(_startDate!, _endDate!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'News',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              TextSpan(
                text: ' Feed',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookmarksPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 48),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search news...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        Provider.of<NewsViewModel>(context, listen: false)
                            .searchNews(_searchController.text);
                      },
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Tech'),
                  Tab(text: 'Politics'),
                  Tab(text: 'Science'),
                  Tab(text: 'Health'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Consumer<NewsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.error.isNotEmpty) {
            return Center(child: Text('Error: ${viewModel.error}'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildNewsList(viewModel),
              _buildNewsList(viewModel),
              _buildNewsList(viewModel),
              _buildNewsList(viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNewsList(NewsViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.articles.length,
      itemBuilder: (context, index) {
        final article = viewModel.articles[index];
        final isBookmarked = viewModel.isBookmarked(article.title);

        return ListTile(
          title: Text(article.title),
          subtitle: Text(article.description ?? ''),
          leading: article.urlToImage.isNotEmpty
              ? Image.network(
                  article.urlToImage,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.blue : null,
                ),
                onPressed: () {
                  if (isBookmarked) {
                    viewModel.removeBookmark(article.title);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Removed from bookmarks')),
                    );
                  } else {
                    viewModel.addBookmark(article);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added to bookmarks')),
                    );
                  }
                },
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleDetailView(article: article),
              ),
            );
          },
        );
      },
    );
  }
}
