import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/post/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeletePost implements UseCase<NoParams, DeletePostParams> {
  final PostRepository postRepository;
  DeletePost(this.postRepository);

  @override
  Future<Either<Failure, NoParams>> call(DeletePostParams params) async {
    return await postRepository.deletePost(
      postId: params.postId,
    );
  }
}

class DeletePostParams {
  final String postId;

  DeletePostParams({required this.postId});
}
