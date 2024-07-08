import 'package:spot_saver/features/post/data/models/post_model.dart';
import 'package:hive/hive.dart';

abstract interface class PostLocalDataSource {
  void uploadLocalPosts({required List<PostModel> posts});
  void uploadLocalFavouritePosts({required List<PostModel> posts});
  List<PostModel> loadPosts();
  List<PostModel> loadFavouritePosts();
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  final Box postBox;

  static const String allPostsKey = 'AllPosts';
  static const String favouritePostsKey = 'FavouritePosts';

  PostLocalDataSourceImpl(this.postBox);

  @override
  List<PostModel> loadPosts() {
    final postsJson = postBox.get(allPostsKey) as List<dynamic>?;
    if (postsJson == null) return [];
    return postsJson
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  void uploadLocalPosts({required List<PostModel> posts}) {
    final postsJson = posts.map((post) => post.toJson()).toList();
    postBox.put(allPostsKey, postsJson);
  }

  @override
  List<PostModel> loadFavouritePosts() {
    final postsJson = postBox.get(favouritePostsKey) as List<dynamic>?;
    if (postsJson == null) return [];
    return postsJson
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  void uploadLocalFavouritePosts({required List<PostModel> posts}) {
    final postsJson = posts.map((post) => post.toJson()).toList();
    postBox.put(favouritePostsKey, postsJson);
  }
}
