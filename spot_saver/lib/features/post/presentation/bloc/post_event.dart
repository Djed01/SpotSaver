part of 'post_bloc.dart';

@immutable
sealed class PostEvent {}

final class PostUpload extends PostEvent {
  final String posterId;
  final String title;
  final String content;
  final File image;
  final List<String> categories;
  final double latitude;
  final double longitude;
  PostUpload(
      {required this.posterId,
      required this.title,
      required this.content,
      required this.image,
      required this.categories,
      required this.latitude,
      required this.longitude});
}

class PostFetchAllPosts extends PostEvent {
  final bool fetchFresh;

  PostFetchAllPosts({this.fetchFresh = false});
}

class PostFetchPosts extends PostEvent {
  final int pageKey;
  final List<String> categories;
  PostFetchPosts(this.pageKey, this.categories);
}

final class PostFilterByCategories extends PostEvent {
  final List<String> selectedCategories;
  PostFilterByCategories(this.selectedCategories);
}

class PostFetchFavouritePosts extends PostEvent {
  final bool fetchFresh;

  PostFetchFavouritePosts({this.fetchFresh = false});
}

class PostFetchUserPosts extends PostEvent {
  final bool fetchFresh;
  PostFetchUserPosts({this.fetchFresh = false});
}

final class PostToggleFavourite extends PostEvent {
  final String postId;

  PostToggleFavourite(this.postId);
}

class PostDelete extends PostEvent {
  final String postId;

  PostDelete({required this.postId});
}

final class PostUpdate extends PostEvent {
  final String postId;
  final String posterId;
  final String title;
  final String content;
  final File? image;
  final String imageUrl;
  final List<String> categories;
  final double latitude;
  final double longitude;
  PostUpdate(
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
