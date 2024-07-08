import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:spot_saver/features/post/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddPostToFavourites implements UseCase<Post, AddPostToFavouritesParams> {
  final PostRepository postRepository;
  AddPostToFavourites(this.postRepository);

  @override
  Future<Either<Failure, Post>> call(AddPostToFavouritesParams params) async {
    return await postRepository.addPostToFavourites(
      userId: params.userId,
      postId: params.postId,
    );
  }
}

class AddPostToFavouritesParams {
  final String userId;
  final String postId;

  AddPostToFavouritesParams({required this.userId, required this.postId});
}
