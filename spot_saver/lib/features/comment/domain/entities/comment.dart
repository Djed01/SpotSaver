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

  Comment copyWith({
    String? id,
    String? userId,
    String? postId,
    String? content,
    DateTime? createdAt,
    String? posterName,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      posterName: posterName ?? this.posterName,
    );
  }
}
