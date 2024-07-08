import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:spot_saver/features/post/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetFavouritePosts
    implements UseCase<List<Post>, GetFavouritePostsParams> {
  final PostRepository postRepository;
  GetFavouritePosts(this.postRepository);

  @override
  Future<Either<Failure, List<Post>>> call(
      GetFavouritePostsParams params) async {
    return await postRepository.getFavouritePosts(params.userId);
  }
}

class GetFavouritePostsParams {
  final String userId;
  GetFavouritePostsParams({required this.userId});
}
