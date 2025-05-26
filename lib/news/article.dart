class Article {
  final String title;
  final String description;
  final String urlToImage;
  final String content;
  final String author;
  final String publishedAt;
  final String url;

  Article({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.content,
    required this.author,
    required this.publishedAt,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? '',
      urlToImage: json['urlToImage'] ??
          'https://via.placeholder.com/150', // fallback image
      content: json['content'] ?? '',
      author: json['author'] ?? 'Unknown',
      publishedAt: json['publishedAt'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
