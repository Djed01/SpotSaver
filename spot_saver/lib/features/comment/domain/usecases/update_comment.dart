import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:spot_saver/features/comment/domain/entities/comment.dart';
import 'package:spot_saver/features/comment/domain/repositories/comment_repository.dart';

class UpdateComment implements UseCase<Comment, UpdateCommentParams> {
  final CommentRepository commentRepository;
  UpdateComment(this.commentRepository);

  @override
  Future<Either<Failure, Comment>> call(UpdateCommentParams params) async {
    return await commentRepository.updateComment(
      commentId: params.commentId,
      content: params.content,
      userId: params.userId,
      postId: params.postId,
      createdAt: params.createdAt,
    );
  }
}

class UpdateCommentParams {
  final String commentId;
  final String content;
  final String userId;
  final String postId;
  final DateTime createdAt;
  UpdateCommentParams({
    required this.commentId,
    required this.content,
    required this.userId,
    required this.postId,
    required this.createdAt,
  });
}
