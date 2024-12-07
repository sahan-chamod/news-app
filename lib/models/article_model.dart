class Article {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String content;
  final String author;
  final String language; 

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.content,
    required this.author,
    required this.language, 
  });


  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'] ?? 'No Content',
      author: json['author'] ?? 'Unknown Author',
      language: json['language'] ?? 'en', 
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
      'author': author,
      'language': language, 
    };
  }

 
  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      title: map['title'] ?? 'No Title',
      description: map['description'] ?? 'No Description',
      url: map['url'] ?? '',
      urlToImage: map['urlToImage'] ?? '',
      publishedAt: map['publishedAt'] ?? '',
      content: map['content'] ?? 'No Content',
      author: map['author'] ?? 'Unknown Author',
      language: map['language'] ?? 'en', 
    );
  }
}
