import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
    'Technology',
    'Politics',
    'Science',
    'Health',
  ];
  Timer? _debounce;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedLanguage;

  final List<String> supportedLanguages = ['en', 'fr', 'es', 'de', 'zh'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }
      String category = categories[_tabController.index].toLowerCase();
      Provider.of<NewsViewModel>(context, listen: false)
          .fetchArticlesByCategory(category);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<NewsViewModel>(context, listen: false);
      viewModel.fetchArticlesByCategory(categories[0].toLowerCase());
      viewModel.fetchBookmarks();
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      Provider.of<NewsViewModel>(context, listen: false)
          .searchNews(_searchController.text);
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
        initialDate: _endDate ?? pickedStartDate,
        firstDate: pickedStartDate,
        lastDate: DateTime.now(),
      );

      if (pickedEndDate != null) {
        setState(() {
          _startDate = pickedStartDate;
          _endDate = pickedEndDate;
        });

        Provider.of<NewsViewModel>(context, listen: false)
            .filterArticlesByDateRange(_startDate!, _endDate!);
      }
    }
  }

  void _selectLanguage(String? language) {
    setState(() {
      _selectedLanguage = language;
    });

    if (language != null) {
      Provider.of<NewsViewModel>(context, listen: false)
          .filterArticlesByLanguage(language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'News Feed',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookmarksPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: _selectLanguage,
            itemBuilder: (context) => supportedLanguages
                .map((lang) => PopupMenuItem(
                      value: lang,
                      child: Text(lang.toUpperCase()),
                    ))
                .toList(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 80),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search news...',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 3,
                    color: Colors.greenAccent,
                  ),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs:
                    categories.map((category) => Tab(text: category)).toList(),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<NewsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error.isNotEmpty) {
            return Center(child: Text('Error: ${viewModel.error}'));
          }

          return TabBarView(
            controller: _tabController,
            children: categories.map((_) => _buildNewsList(viewModel)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildNewsList(NewsViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: viewModel.articles.length,
      itemBuilder: (context, index) {
        final article = viewModel.articles[index];
        final isBookmarked = viewModel.isBookmarked(article.title);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 5,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailView(article: article),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.urlToImage.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                    ),
                    child: Image.network(
                      article.urlToImage,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article.description ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isBookmarked
                                    ? Colors.blueAccent
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                if (isBookmarked) {
                                  viewModel.removeBookmark(article.title);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Removed from bookmarks')),
                                  );
                                } else {
                                  viewModel.addBookmark(article);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Added to bookmarks')),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.grey),
                              onPressed: () {
                                final String shareText =
                                    '${article.title}\n\n${article.description ?? ''}\nRead more: ${article.url}';
                                Share.share(shareText);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
