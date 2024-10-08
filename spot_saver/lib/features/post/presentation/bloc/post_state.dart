part of 'post_bloc.dart';

@immutable
sealed class PostState {}

final class PostInitial extends PostState {}

final class PostLoading extends PostState {}

final class PostFailure extends PostState {
  final String error;
  PostFailure(this.error);
}

final class PostUploadSuccess extends PostState {}

final class PostDisplaySuccess extends PostState {
  final List<Post> posts;
  PostDisplaySuccess(this.posts);
}

final class PostFetchPostsSuccess extends PostState {
  final List<Post> posts;
  PostFetchPostsSuccess(this.posts);
}

final class PostFilteredSuccess extends PostState {
  final List<Post> filteredPosts;
  PostFilteredSuccess(this.filteredPosts);
}

final class PostFavouritesSuccess extends PostState {
  final List<Post> favouritePosts;
  PostFavouritesSuccess(this.favouritePosts);
}

final class PostUserPostsSuccess extends PostState {
  final List<Post> userPosts;
  PostUserPostsSuccess(this.userPosts);
}

final class PostToggleFavouriteSuccess extends PostState {
  final Post post;
  final bool isFavourite;

  PostToggleFavouriteSuccess(this.post, this.isFavourite);
}

final class PostDeleteSuccess extends PostState {}

final class PostUpdateSuccess extends PostState {}
