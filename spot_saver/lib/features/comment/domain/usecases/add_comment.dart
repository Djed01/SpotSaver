import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:spot_saver/features/comment/domain/entities/comment.dart';
import 'package:spot_saver/features/comment/domain/repositories/comment_repository.dart';

class AddComment implements UseCase<Comment, AddCommentParams> {
  final CommentRepository commentRepository;
  AddComment(this.commentRepository);

  @override
  Future<Either<Failure, Comment>> call(AddCommentParams params) async {
    return await commentRepository.addComment(
        postId: params.postId, content: params.content, userId: params.userId);
  }
}

class AddCommentParams {
  final String userId;
  final String postId;
  final String content;
  AddCommentParams({
    required this.userId,
    required this.postId,
    required this.content,
  });
}
