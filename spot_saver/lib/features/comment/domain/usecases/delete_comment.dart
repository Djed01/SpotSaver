import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/comment/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteComment implements UseCase<NoParams, DeleteCommentParams> {
  final CommentRepository commentRepository;
  DeleteComment(this.commentRepository);

  @override
  Future<Either<Failure, NoParams>> call(DeleteCommentParams params) async {
    return await commentRepository.deleteComment(
      commentId: params.commentId,
    );
  }
}

class DeleteCommentParams {
  final String commentId;

  DeleteCommentParams({required this.commentId});
}
