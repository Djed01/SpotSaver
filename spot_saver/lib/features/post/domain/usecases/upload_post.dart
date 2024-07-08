import 'dart:io';

import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:spot_saver/features/post/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class UploadPost implements UseCase<Post, UploadPostParams> {
  final PostRepository postRepository;
  UploadPost(this.postRepository);

  @override
  Future<Either<Failure, Post>> call(UploadPostParams params) async {
    return await postRepository.uploadPost(
        image: params.image,
        title: params.title,
        content: params.content,
        posterId: params.posterId,
        categories: params.categories,
        latitude: params.latitude,
        longitude: params.longitude);
  }
}

class UploadPostParams {
  final String posterId;
  final String title;
  final String content;
  final File image;
  final double latitude;
  final double longitude;
  final List<String> categories;
  UploadPostParams(
      {required this.posterId,
      required this.title,
      required this.content,
      required this.image,
      required this.categories,
      required this.latitude,
      required this.longitude});
}
