import 'package:spot_saver/core/constants/constants.dart';
import 'package:spot_saver/core/error/exceptions.dart';
import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/network/connection_checker.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/comment/data/datasources/comment_remote_datasource.dart';
import 'package:spot_saver/features/comment/data/models/comment_model.dart';
import 'package:spot_saver/features/comment/domain/entities/comment.dart';
import 'package:spot_saver/features/comment/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource commentRemoteDataSource;
  final ConnectionChecker connectionChecker;
  CommentRepositoryImpl(
    this.commentRemoteDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, List<Comment>>> getComments(
      int pageKey, String postId) async {
    try {
      if (!await connectionChecker.isConnected) {
        // final posts = postLocalDataSource.loadPosts();
        // return right(posts);
      }
      final comments =
          await commentRemoteDataSource.getComments(pageKey, postId);
      return right(comments);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Comment>> addComment(
      {required String postId,
      required String content,
      required String userId}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      CommentModel commentModel = CommentModel(
        id: const Uuid().v1(),
        userId: userId,
        postId: postId,
        content: content,
        createdAt: DateTime.now(),
      );

      final addedComment =
          await commentRemoteDataSource.addComment(commentModel);
      return right(addedComment);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, NoParams>> deleteComment(
      {required String commentId}) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      await commentRemoteDataSource.deleteComment(
        commentId: commentId,
      );

      return right(NoParams());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Comment>> updateComment(
      {required String commentId,
      required String content,
      required String userId,
      required String postId,
      required DateTime createdAt}) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      CommentModel commentModel = CommentModel(
        id: commentId,
        content: content,
        userId: userId,
        postId: postId,
        createdAt: createdAt,
      );

      final updatedComment =
          await commentRemoteDataSource.updateComment(commentModel);
      return right(updatedComment);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
