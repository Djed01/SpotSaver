import 'package:spot_saver/core/common/widgets/loader.dart';
import 'package:spot_saver/core/constants/constants.dart';
import 'package:spot_saver/core/theme/app_pallete.dart';
import 'package:spot_saver/core/utils/show_snackbar.dart';
import 'package:spot_saver/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:spot_saver/features/auth/presentation/pages/change_password.dart';
import 'package:spot_saver/features/auth/presentation/pages/login_page.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:spot_saver/features/post/presentation/bloc/post_bloc.dart';
import 'package:spot_saver/features/post/presentation/pages/add_new_post_page.dart';
import 'package:spot_saver/features/post/presentation/pages/favourite_posts_page.dart';
import 'package:spot_saver/features/post/presentation/pages/user_posts_page.dart';
import 'package:spot_saver/features/post/presentation/widgets/main_drawer.dart';
import 'package:spot_saver/features/post/presentation/widgets/post_card.dart';
import 'package:spot_saver/features/post/presentation/widgets/post_category_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostsPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const PostsPage(),
      );
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final controller = ScrollController();
  int page = 0;
  bool isLoading = false;
  bool hasMore = true;
  List<Post> posts = [];
  List<String> selectedCategories = [];
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const PostPageContent(),
    const UserPostsPage(),
    const FavoritePostsPage(),
  ];

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (controller.position.pixels >= controller.position.maxScrollExtent &&
        !isLoading &&
        hasMore) {
      _fetchPosts();
    }
  }

  Future<void> _fetchPosts() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    context.read<PostBloc>().add(PostFetchPosts(page, selectedCategories));
  }

  void _onPostsFetched(List<Post> newPosts) {
    setState(() {
      if (newPosts.length < Constants.numberOfPostsPerRequest) {
        hasMore = false;
      }
      page++;
      posts.addAll(newPosts);
      isLoading = false;
    });
  }

  Future<void> _refreshPostData() async {
    setState(() {
      page = 0;
      posts.clear();
      hasMore = true;
    });
    await _fetchPosts();
  }

  Future<void> _refreshFavouritesData() async {
    context.read<PostBloc>().add(PostFetchFavouritePosts(fetchFresh: true));
  }

  Future<void> _refreshUserData() async {
    context.read<PostBloc>().add(PostFetchUserPosts(fetchFresh: true));
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategories.add(category);
    });
    _refreshPostData();
  }

  void _onCategoryDeselected(String category) {
    setState(() {
      selectedCategories.remove(category);
    });
    _refreshPostData();
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      context.read<PostBloc>().add(PostFetchAllPosts());
    } else if (index == 1) {
      context.read<PostBloc>().add(PostFetchUserPosts());
    } else if (index == 2) {
      context.read<PostBloc>().add(PostFetchFavouritePosts());
    }
  }

  void _handleDrawerSelection(String identifier) {
    Navigator.of(context).pop(); // Close the drawer
    if (identifier == 'change_password') {
      Navigator.push(context, ChangePasswordPage.route());
    } else if (identifier == 'logout') {
      context.read<AuthBloc>().add(AuthLogout());
      Navigator.pushAndRemoveUntil(
          context, LoginPage.route(), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text('Spot Saver'),
              centerTitle: true,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(context, AddNewPostPage.route());
                  },
                  icon: const Icon(
                    CupertinoIcons.add_circled,
                  ),
                ),
              ],
            )
          : null,
      drawer: MainDrawer(onSelectScreen: _handleDrawerSelection),
      body: RefreshIndicator(
        onRefresh: () {
          if (_currentIndex == 0) {
            return _refreshPostData();
          } else if (_currentIndex == 1) {
            return _refreshUserData();
          } else {
            return _refreshFavouritesData();
          }
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'My Posts'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
        ],
      ),
    );
  }
}

class PostPageContent extends StatelessWidget {
  const PostPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostFailure) {
          showSnackBar(context, state.error);
        } else if (state is PostFetchPostsSuccess) {
          (context.findAncestorStateOfType<_PostsPageState>())
              ?._onPostsFetched(state.posts);
        }
      },
      builder: (context, state) {
        final posts =
            (context.findAncestorStateOfType<_PostsPageState>())?.posts ?? [];
        final hasMore =
            (context.findAncestorStateOfType<_PostsPageState>())?.hasMore ??
                false;

        if (state is PostLoading && posts.isEmpty) {
          return Column(
            children: [
              PostCategoryWidget(
                selectedCategories:
                    (context.findAncestorStateOfType<_PostsPageState>())!
                        .selectedCategories,
                onCategorySelected:
                    (context.findAncestorStateOfType<_PostsPageState>())!
                        ._onCategorySelected,
                onCategoryDeselected:
                    (context.findAncestorStateOfType<_PostsPageState>())!
                        ._onCategoryDeselected,
              ),
              const SizedBox(height: 16),
              const Loader(),
            ],
          );
        }

        return Column(
          children: [
            PostCategoryWidget(
              selectedCategories:
                  (context.findAncestorStateOfType<_PostsPageState>())!
                      .selectedCategories,
              onCategorySelected:
                  (context.findAncestorStateOfType<_PostsPageState>())!
                      ._onCategorySelected,
              onCategoryDeselected:
                  (context.findAncestorStateOfType<_PostsPageState>())!
                      ._onCategoryDeselected,
            ),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  controller:
                      (context.findAncestorStateOfType<_PostsPageState>())!
                          .controller,
                  itemCount: posts.length + 1,
                  itemBuilder: (context, index) {
                    if (index < posts.length) {
                      final post = posts[index];
                      return PostCard(
                        post: post,
                        color: index % 4 == 0
                            ? AppPallete.cardColor1
                            : index % 4 == 1
                                ? AppPallete.cardColor2
                                : index % 4 == 2
                                    ? AppPallete.cardColor3
                                    : AppPallete.cardColor4,
                        textColor: index % 4 == 0
                            ? const Color.fromRGBO(255, 255, 255, 1)
                            : index % 4 == 1
                                ? const Color.fromRGBO(255, 255, 255, 1)
                                : index % 4 == 2
                                    ? const Color.fromRGBO(0, 0, 0, 1)
                                    : const Color.fromRGBO(0, 0, 0, 1),
                        sourcePage: SourcePage.home,
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: hasMore
                              ? const CircularProgressIndicator()
                              : const Text('No more data to load'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
