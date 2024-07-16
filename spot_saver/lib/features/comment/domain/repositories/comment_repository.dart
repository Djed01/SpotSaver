import 'package:spot_saver/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/comment/domain/entities/comment.dart';

abstract interface class CommentRepository {
  Future<Either<Failure, List<Comment>>> getComments(
      int pageKey, String postId);

  Future<Either<Failure, Comment>> addComment({
    required String postId,
    required String content,
    required String userId,
  });

  Future<Either<Failure, NoParams>> deleteComment({
    required String commentId,
  });

  Future<Either<Failure, Comment>> updateComment({
    required String commentId,
    required String content,
    required String userId,
    required String postId,
    required DateTime createdAt,
  });
}
