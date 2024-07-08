class Post {
  final String id;
  final String posterId;
  final String title;
  final String content;
  final String imageUrl;
  final List<String> categories;
  final DateTime updatedAt;
  final double latitude;
  final double longitude;
  final String? posterName;

  Post({
    required this.id,
    required this.posterId,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.categories,
    required this.updatedAt,
    required this.latitude,
    required this.longitude,
    this.posterName,
  });
}
