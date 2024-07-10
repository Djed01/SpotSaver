import 'dart:io';
import 'package:spot_saver/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:spot_saver/features/post/domain/usecases/add_post_to_favourites.dart';
import 'package:spot_saver/features/post/domain/usecases/delete_post.dart';
import 'package:spot_saver/features/post/domain/usecases/get_all_posts.dart';
import 'package:spot_saver/features/post/domain/usecases/get_favourite_posts.dart';
import 'package:spot_saver/features/post/domain/usecases/get_user_posts.dart';
import 'package:spot_saver/features/post/domain/usecases/remove_post_from_favourites.dart';
import 'package:spot_saver/features/post/domain/usecases/upload_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final UploadPost _uploadPost;
  final GetAllPosts _getAllPosts;
  final GetFavouritePosts _getFavouritePosts;
  final GetUserPosts _getUserPosts;
  final AddPostToFavourites _addPostToFavourites;
  final RemovePostFromFavourites _removePostFromFavourites;
  final DeletePost _deletePost;
  final AppUserCubit _appUserCubit;
  List<Post> _cachedPosts = [];
  List<Post> _cachedFavouritePosts = [];
  List<Post> _cachedUserPosts = [];

  PostBloc({
    required UploadPost uploadPost,
    required GetAllPosts getAllPosts,
    required GetFavouritePosts getFavouritePosts,
    required GetUserPosts getUserPosts,
    required AddPostToFavourites addPostToFavourites,
    required RemovePostFromFavourites removePostFromFavourites,
    required DeletePost deletePost,
    required AppUserCubit appUserCubit,
  })  : _uploadPost = uploadPost,
        _getAllPosts = getAllPosts,
        _getFavouritePosts = getFavouritePosts,
        _getUserPosts = getUserPosts,
        _addPostToFavourites = addPostToFavourites,
        _removePostFromFavourites = removePostFromFavourites,
        _deletePost = deletePost,
        _appUserCubit = appUserCubit,
        super(PostInitial()) {
    on<PostUpload>(_onPostUpload);
    on<PostFetchAllPosts>(_onFetchAllPosts);
    on<PostFilterByCategories>(_onFilterByCategories);
    on<PostFetchFavouritePosts>(_onFetchFavouritePosts);
    on<PostToggleFavourite>(_onToggleFavourite);
    on<PostDelete>(_onDeletePost);
    on<PostFetchUserPosts>(_onFetchUserPosts);

    // Load Posts and favourites when bloc is initialized
    add(PostFetchAllPosts(fetchFresh: true));
    add(PostFetchFavouritePosts(fetchFresh: true));
    add(PostFetchUserPosts(fetchFresh: true));
  }

  void _onPostUpload(PostUpload event, Emitter<PostState> emit) async {
    final res = await _uploadPost(UploadPostParams(
        posterId: event.posterId,
        title: event.title,
        content: event.content,
        image: event.image,
        categories: event.categories,
        latitude: event.latitude,
        longitude: event.longitude));

    res.fold(
        (l) => emit(PostFailure(l.message)), (r) => emit(PostUploadSuccess()));
  }

  void _onFetchAllPosts(
      PostFetchAllPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());

    if (!event.fetchFresh && _cachedPosts.isNotEmpty) {
      emit(PostDisplaySuccess(_cachedPosts));
      return;
    }

    final res = await _getAllPosts(NoParams());

    res.fold(
      (l) => emit(PostFailure(l.message)),
      (r) {
        _cachedPosts = r;
        emit(PostDisplaySuccess(r));
      },
    );
  }

  void _onFetchFavouritePosts(
      PostFetchFavouritePosts event, Emitter<PostState> emit) async {
    emit(PostLoading());

    final currentState = _appUserCubit.state;
    if (currentState is AppUserLoggedIn) {
      final userId = currentState.user.id;
      if (!event.fetchFresh && _cachedFavouritePosts.isNotEmpty) {
        emit(PostFavouritesSuccess(_cachedFavouritePosts));
        return;
      }

      final res =
          await _getFavouritePosts(GetFavouritePostsParams(userId: userId));

      res.fold(
        (l) => emit(PostFailure(l.message)),
        (r) {
          _cachedFavouritePosts = r;
          emit(PostFavouritesSuccess(r));
        },
      );
    } else {
      emit(PostFailure("User not logged in"));
    }
  }

  void _onFetchUserPosts(
      PostFetchUserPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());

    final currentState = _appUserCubit.state;
    if (currentState is AppUserLoggedIn) {
      final userId = currentState.user.id;
      if (!event.fetchFresh && _cachedUserPosts.isNotEmpty) {
        emit(PostUserPostsSuccess(_cachedUserPosts));
        return;
      }

      final res = await _getUserPosts(GetUserPostsParams(userId: userId));

      res.fold(
        (l) => emit(PostFailure(l.message)),
        (r) {
          _cachedUserPosts = r;
          emit(PostUserPostsSuccess(r));
        },
      );
    } else {
      emit(PostFailure("User not logged in"));
    }
  }

  void _onFilterByCategories(
      PostFilterByCategories event, Emitter<PostState> emit) {
    if (event.selectedCategories.isEmpty) {
      if (_cachedPosts.isNotEmpty) {
        emit(PostFilteredSuccess(_cachedPosts));
      } else {
        emit(PostFailure("No Posts available"));
      }
    } else {
      final filteredPosts = _cachedPosts
          .where((post) => post.categories
              .any((category) => event.selectedCategories.contains(category)))
          .toList();
      emit(PostFilteredSuccess(filteredPosts));
    }
  }

  void _onToggleFavourite(
      PostToggleFavourite event, Emitter<PostState> emit) async {
    final currentState = _appUserCubit.state;
    if (currentState is AppUserLoggedIn) {
      final userId = currentState.user.id;

      final isFavourite =
          _cachedFavouritePosts.any((p) => p.id == event.postId);

      if (isFavourite) {
        // Remove from favourites
        final res = await _removePostFromFavourites(
          RemovePostFromFavouritesParams(userId: userId, postId: event.postId),
        );

        res.fold(
          (l) => emit(PostFailure(l.message)),
          (r) {
            final removedPost =
                _cachedFavouritePosts.firstWhere((p) => p.id == event.postId);
            _cachedFavouritePosts.removeWhere((p) => p.id == event.postId);
            emit(PostToggleFavouriteSuccess(removedPost, false));
          },
        );
      } else {
        // Add to favourites
        final res = await _addPostToFavourites(
          AddPostToFavouritesParams(userId: userId, postId: event.postId),
        );

        res.fold(
          (l) => emit(PostFailure(l.message)),
          (r) {
            final addedPost =
                _cachedPosts.firstWhere((p) => p.id == event.postId);
            _cachedFavouritePosts.add(addedPost);
            emit(PostToggleFavouriteSuccess(addedPost, true));
          },
        );
      }
    } else {
      emit(PostFailure("User not logged in"));
    }
  }

  void _onDeletePost(PostDelete event, Emitter<PostState> emit) async {
    emit(PostLoading());

    final res = await _deletePost(DeletePostParams(postId: event.postId));

    res.fold(
      (l) => emit(PostFailure(l.message)),
      (r) {
        _cachedPosts.removeWhere((p) => p.id == event.postId);
        _cachedFavouritePosts.removeWhere((p) => p.id == event.postId);
        _cachedUserPosts.removeWhere((p) => p.id == event.postId);
        emit(PostDeleteSuccess());
      },
    );
  }
}
