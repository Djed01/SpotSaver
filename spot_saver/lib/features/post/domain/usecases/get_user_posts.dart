import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:spot_saver/features/post/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetUserPosts implements UseCase<List<Post>, GetUserPostsParams> {
  final PostRepository postRepository;
  GetUserPosts(this.postRepository);

  @override
  Future<Either<Failure, List<Post>>> call(GetUserPostsParams params) async {
    return await postRepository.getUserPosts(params.userId);
  }
}

class GetUserPostsParams {
  final String userId;
  GetUserPostsParams({required this.userId});
}
