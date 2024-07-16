class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? posterName;

  Comment(
      {required this.id,
      required this.postId,
      required this.userId,
      required this.content,
      required this.createdAt,
      this.posterName});
}
