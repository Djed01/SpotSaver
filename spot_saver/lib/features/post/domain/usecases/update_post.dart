import 'dart:io';

import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:spot_saver/features/post/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdatePost implements UseCase<Post, UpdatePostParams> {
  final PostRepository postRepository;
  UpdatePost(this.postRepository);

  @override
  Future<Either<Failure, Post>> call(UpdatePostParams params) async {
    return await postRepository.updatePost(
        image: params.image,
        imageUrl: params.imageUrl,
        postId: params.postId,
        title: params.title,
        content: params.content,
        posterId: params.posterId,
        categories: params.categories,
        latitude: params.latitude,
        longitude: params.longitude);
  }
}

class UpdatePostParams {
  final String postId;
  final String posterId;
  final String title;
  final String content;
  final File? image;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final List<String> categories;
  UpdatePostParams(
      {required this.postId,
      required this.posterId,
      required this.title,
      required this.content,
      required this.image,
      required this.imageUrl,
      required this.categories,
      required this.latitude,
      required this.longitude});
}
