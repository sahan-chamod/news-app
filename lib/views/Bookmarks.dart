import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/news_viewmodel.dart';
import 'article_detail_view.dart';

class BookmarksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarked Articles'),
      ),
      body: Consumer<NewsViewModel>(
        builder: (context, viewModel, child) {
          // Get the list of bookmarked articles
          final bookmarkedArticles = viewModel.bookmarkedArticles;

          if (bookmarkedArticles.isEmpty) {
            return Center(child: Text('No bookmarks found.'));
          }

          return ListView.builder(
            itemCount: bookmarkedArticles.length,
            itemBuilder: (context, index) {
              final article = bookmarkedArticles[index];

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
                trailing: IconButton(
                  icon: Icon(Icons.bookmark, color: Colors.blue),
                  onPressed: () {
                    viewModel.removeBookmark(article.title);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Removed from bookmarks')),
                    );
                  },
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
        },
      ),
    );
  }
}
