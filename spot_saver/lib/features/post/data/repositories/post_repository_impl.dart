import 'dart:io';

import 'package:spot_saver/core/constants/constants.dart';
import 'package:spot_saver/core/error/exceptions.dart';
import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/network/connection_checker.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/post/data/datasources/post_local_data_source.dart';
import 'package:spot_saver/features/post/data/datasources/post_remote_data_source.dart';
import 'package:spot_saver/features/post/data/models/post_model.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:spot_saver/features/post/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource postRemoteDataSource;
  final PostLocalDataSource postLocalDataSource;
  final ConnectionChecker connectionChecker;
  PostRepositoryImpl(
    this.postRemoteDataSource,
    this.postLocalDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, Post>> uploadPost({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required double latitude,
    required double longitude,
    required List<String> categories,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      PostModel postModel = PostModel(
        id: const Uuid().v1(),
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: '',
        categories: categories,
        latitude: latitude,
        longitude: longitude,
        updatedAt: DateTime.now(),
      );

      final imageUrl = await postRemoteDataSource.uploadPostImage(
        image: image,
        post: postModel,
      );

      postModel = postModel.copyWith(
        imageUrl: imageUrl,
      );

      final uploadedPost = await postRemoteDataSource.uploadPost(postModel);
      return right(uploadedPost);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getAllPosts() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final posts = postLocalDataSource.loadPosts();
        return right(posts);
      }
      final posts = await postRemoteDataSource.getAllPosts();
      postLocalDataSource.uploadLocalPosts(posts: posts);

      return right(posts);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getFavouritePosts(String userId) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final posts = postLocalDataSource.loadFavouritePosts();
        return right(posts);
      }
      final posts = await postRemoteDataSource.getFavouritesPosts(userId);
      postLocalDataSource.uploadLocalFavouritePosts(posts: posts);

      return right(posts);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Post>> addPostToFavourites({
    required String userId,
    required String postId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final favourite = await postRemoteDataSource.addPostToFavourites(
        userId: userId,
        postId: postId,
      );

      return right(favourite);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, NoParams>> removePostFromFavourites({
    required String userId,
    required String postId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      await postRemoteDataSource.removePostFromFavourites(
        userId: userId,
        postId: postId,
      );

      return right(NoParams());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
