import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/post/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class RemovePostFromFavourites
    implements UseCase<NoParams, RemovePostFromFavouritesParams> {
  final PostRepository postRepository;
  RemovePostFromFavourites(this.postRepository);

  @override
  Future<Either<Failure, NoParams>> call(
      RemovePostFromFavouritesParams params) async {
    return await postRepository.removePostFromFavourites(
      userId: params.userId,
      postId: params.postId,
    );
  }
}

class RemovePostFromFavouritesParams {
  final String userId;
  final String postId;

  RemovePostFromFavouritesParams({required this.userId, required this.postId});
}
