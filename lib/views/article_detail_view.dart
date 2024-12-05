
import 'package:flutter/material.dart';
import '../models/article_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailView extends StatelessWidget {
  final Article article;

  const ArticleDetailView({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.urlToImage.isNotEmpty)
                Image.network(
                  article.urlToImage,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 16),
              Text(
                article.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              Text(
                'By ${article.author}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                'Published on: ${article.publishedAt}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: 16),
              Text(
                article.description ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 16),
              Text(
                article.content ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _launchURL(article.url),
                child: Text('Read Full Article'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
