import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_saver/features/comment/domain/entities/comment.dart';
import 'package:spot_saver/features/comment/domain/usecases/add_comment.dart';
import 'package:spot_saver/features/comment/domain/usecases/delete_comment.dart';
import 'package:spot_saver/features/comment/domain/usecases/get_comments.dart';
import 'package:spot_saver/features/comment/domain/usecases/update_comment.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetComments _getComments;
  final AddComment _addComment;
  final DeleteComment _deleteComment;
  final UpdateComment _updateComment;

  CommentBloc({
    required GetComments getComments,
    required AddComment addComment,
    required DeleteComment deleteComment,
    required UpdateComment updateComment,
  })  : _getComments = getComments,
        _addComment = addComment,
        _deleteComment = deleteComment,
        _updateComment = updateComment,
        super(CommentInitial()) {
    on<CommentFetchComments>(_onFetchComments);
    on<CommentAddComment>(_onAddComment);
    on<CommentDeleteComment>(_onDeleteComment);
    on<CommentUpdateComment>(_onUpdateComment);
  }

  void _onFetchComments(
      CommentFetchComments event, Emitter<CommentState> emit) async {
    if (event.pageKey == 0) emit(CommentLoading());

    final res =
        await _getComments(GetCommentsParams(event.pageKey, event.postId));

    res.fold(
      (l) => emit(CommentError(l.message)),
      (r) => emit(CommentLoaded(r)),
    );
  }

  void _onAddComment(
      CommentAddComment event, Emitter<CommentState> emit) async {
    final res = await _addComment(AddCommentParams(
      userId: event.userId,
      postId: event.postId,
      content: event.content,
    ));

    res.fold(
      (l) => emit(CommentError(l.message)),
      (r) => emit(CommentAdded(r)),
    );
  }

  void _onDeleteComment(
      CommentDeleteComment event, Emitter<CommentState> emit) async {
    final res =
        await _deleteComment(DeleteCommentParams(commentId: event.commentId));

    res.fold(
      (l) => emit(CommentError(l.message)),
      (r) {
        emit(CommentDeleted(event.commentId));
      },
    );
  }

  void _onUpdateComment(
      CommentUpdateComment event, Emitter<CommentState> emit) async {
    final res = await _updateComment(UpdateCommentParams(
        commentId: event.comment.id,
        content: event.comment.content,
        createdAt: event.comment.createdAt,
        postId: event.comment.postId,
        userId: event.comment.userId));

    res.fold(
      (l) => emit(CommentError(l.message)),
      (r) {
        emit(CommentUpdated(r));
      },
    );
  }
}
