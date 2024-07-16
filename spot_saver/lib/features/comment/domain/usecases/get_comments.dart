import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:spot_saver/features/comment/domain/entities/comment.dart';
import 'package:spot_saver/features/comment/domain/repositories/comment_repository.dart';

class GetComments implements UseCase<List<Comment>, GetCommentsParams> {
  final CommentRepository commentRepository;
  GetComments(this.commentRepository);

  @override
  Future<Either<Failure, List<Comment>>> call(GetCommentsParams params) async {
    return await commentRepository.getComments(params.pageKey, params.postId);
  }
}

class GetCommentsParams {
  final int pageKey;
  final String postId;
  GetCommentsParams(this.pageKey, this.postId);
}
