import 'dart:io';

import 'package:spot_saver/core/error/exceptions.dart';
import 'package:spot_saver/features/post/data/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class PostRemoteDataSource {
  Future<PostModel> uploadPost(PostModel post);
  Future<String> uploadPostImage({
    required File image,
    required PostModel post,
  });
  Future<List<PostModel>> getAllPosts();
  Future<List<PostModel>> getFavouritesPosts(String userId);
  Future<List<PostModel>> getUserPosts(String userId);
  Future<PostModel> addPostToFavourites({
    required String userId,
    required String postId,
  });
  Future<void> removePostFromFavourites({
    required String userId,
    required String postId,
  });
  Future<void> deletePost({required String postId});
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final SupabaseClient supabaseClient;
  PostRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<PostModel> uploadPost(PostModel post) async {
    try {
      final postData =
          await supabaseClient.from('posts').insert(post.toJson()).select();

      return PostModel.fromJson(postData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadPostImage(
      {required File image, required PostModel post}) async {
    try {
      await supabaseClient.storage.from('post_images').upload(
            post.id,
            image,
          );

      return supabaseClient.storage.from('post_images').getPublicUrl(post.id);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PostModel>> getAllPosts() async {
    try {
      final posts =
          await supabaseClient.from('posts').select('*, profiles (name)');
      return posts
          .map((post) => PostModel.fromJson(post).copyWith(
                posterName: post['profiles']['name'],
              ))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PostModel>> getFavouritesPosts(String userId) async {
    try {
      final favouritePosts = await supabaseClient
          .from('favourites')
          .select(
              'posts(id, updated_at, poster_id, title, content, image_url, categories,longitude,latitude)')
          .eq('user_id', userId);

      return favouritePosts
          .map((post) => PostModel.fromJson(post['posts']).copyWith(
                posterName:
                    post['profiles'] != null ? post['profiles']['name'] : '',
              ))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final userPosts = await supabaseClient
          .from('posts')
          .select(
              'id, updated_at, poster_id, title, content, image_url, categories, longitude, latitude, profiles(name)')
          .eq('poster_id', userId);

      return userPosts
          .map((post) => PostModel.fromJson(post).copyWith(
                posterName:
                    post['profiles'] != null ? post['profiles']['name'] : '',
              ))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PostModel> addPostToFavourites(
      {required String userId, required String postId}) async {
    try {
      final data = {
        'user_id': userId,
        'post_id': postId,
      };

      await supabaseClient.from('favourites').insert(data).select().single();
      final postData =
          await supabaseClient.from('posts').select().eq('id', postId).single();
      return PostModel.fromJson(postData);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removePostFromFavourites({
    required String userId,
    required String postId,
  }) async {
    try {
      await supabaseClient
          .from('favourites')
          .delete()
          .eq('user_id', userId)
          .eq('post_id', postId);
    } on PostgrestException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deletePost({required String postId}) async {
    try {
      // Delete the post image
      await supabaseClient.storage.from('post_images').remove([postId]);

      // Delete the post data
      await supabaseClient.from('posts').delete().eq('id', postId);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } on PostgrestException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
