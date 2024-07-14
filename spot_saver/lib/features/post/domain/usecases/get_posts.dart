import 'package:fpdart/fpdart.dart';
import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:spot_saver/features/post/domain/repositories/post_repository.dart';

class GetPosts implements UseCase<List<Post>, PaginationParams> {
  final PostRepository postRepository;

  GetPosts(this.postRepository);

  @override
  Future<Either<Failure, List<Post>>> call(PaginationParams params) async {
    return await postRepository.getPosts(params.pageKey, params.categories);
  }
}

class PaginationParams {
  final int pageKey;
  final List<String> categories;

  PaginationParams(this.pageKey, this.categories);
}
