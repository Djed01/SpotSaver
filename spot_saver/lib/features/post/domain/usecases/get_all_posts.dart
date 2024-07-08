import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:spot_saver/features/post/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllPosts implements UseCase<List<Post>, NoParams> {
  final PostRepository postRepository;
  GetAllPosts(this.postRepository);

  @override
  Future<Either<Failure, List<Post>>> call(NoParams params) async {
    return await postRepository.getAllPosts();
  }
}
