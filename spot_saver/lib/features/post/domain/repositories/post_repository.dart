import 'dart:io';

import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PostRepository {
  Future<Either<Failure, Post>> uploadPost(
      {required File image,
      required String title,
      required String content,
      required String posterId,
      required List<String> categories,
      required double latitude,
      required double longitude});

  Future<Either<Failure, Post>> addPostToFavourites({
    required String userId,
    required String postId,
  });

  Future<Either<Failure, NoParams>> removePostFromFavourites({
    required String userId,
    required String postId,
  });

  Future<Either<Failure, NoParams>> deletePost({
    required String postId,
  });

  Future<Either<Failure, List<Post>>> getAllPosts();

  Future<Either<Failure, List<Post>>> getPosts(
      int pageKey, List<String> categories);

  Future<Either<Failure, List<Post>>> getFavouritePosts(String userId);

  Future<Either<Failure, List<Post>>> getUserPosts(String userId);

  Future<Either<Failure, Post>> updatePost(
      {required File? image,
      required String imageUrl,
      required String postId,
      required String title,
      required String content,
      required String posterId,
      required double latitude,
      required double longitude,
      required List<String> categories});
}
