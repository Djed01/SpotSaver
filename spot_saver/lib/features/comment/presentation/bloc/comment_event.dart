part of 'comment_bloc.dart';

@immutable
sealed class CommentEvent {}

class CommentFetchComments extends CommentEvent {
  final int pageKey;
  final String postId;
  CommentFetchComments(this.pageKey, this.postId);
}

class CommentAddComment extends CommentEvent {
  final String postId;
  final String userId;
  final String content;
  CommentAddComment({
    required this.postId,
    required this.userId,
    required this.content,
  });
}

class CommentDeleteComment extends CommentEvent {
  final String commentId;
  CommentDeleteComment({
    required this.commentId,
  });
}

class CommentUpdateComment extends CommentEvent {
  final Comment comment;
  CommentUpdateComment({required this.comment});
}
