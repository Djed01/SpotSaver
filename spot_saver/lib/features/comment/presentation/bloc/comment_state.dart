part of 'comment_bloc.dart';

@immutable
sealed class CommentState {}

final class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {
  final List<Comment> comments;
  CommentLoaded(this.comments);
}

class CommentError extends CommentState {
  final String message;
  CommentError(this.message);
}

class CommentAdded extends CommentState {
  final Comment comment;
  CommentAdded(this.comment);
}

class CommentDeleted extends CommentState {
  final String commentId;

  CommentDeleted(this.commentId);
}

class CommentUpdated extends CommentState {
  final Comment comment;
  CommentUpdated(this.comment);
}
