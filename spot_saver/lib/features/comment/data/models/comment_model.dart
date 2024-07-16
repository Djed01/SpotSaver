import 'package:spot_saver/features/comment/domain/entities/comment.dart';

class CommentModel extends Comment {
  CommentModel(
      {required super.id,
      required super.postId,
      required super.userId,
      required super.content,
      required super.createdAt,
      super.posterName});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      userId: map['user_id'] as String,
      content: map['content'] as String,
      createdAt: map['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['created_at']),
    );
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    DateTime? createdAt,
    String? posterName,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      posterName: posterName ?? this.posterName,
    );
  }
}
