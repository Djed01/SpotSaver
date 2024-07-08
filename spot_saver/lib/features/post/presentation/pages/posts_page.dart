import 'package:spot_saver/core/common/widgets/loader.dart';
import 'package:spot_saver/core/theme/app_pallete.dart';
import 'package:spot_saver/core/utils/show_snackbar.dart';
import 'package:spot_saver/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:spot_saver/features/auth/presentation/pages/login_page.dart';
import 'package:spot_saver/features/post/presentation/bloc/post_bloc.dart';
import 'package:spot_saver/features/post/presentation/pages/add_new_post_page.dart';
import 'package:spot_saver/features/post/presentation/pages/favourite_posts_page.dart';
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
  List<String> selectedCategories = [];
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const PostPageContent(),
    const FavoritePostsPage()
  ];

  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(PostFetchAllPosts());
  }

  Future<void> _refreshPostData() async {
    context.read<PostBloc>().add(PostFetchAllPosts(fetchFresh: true));
  }

  Future<void> _refreshFavouritesData() async {
    context.read<PostBloc>().add(PostFetchFavouritePosts(fetchFresh: true));
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategories.add(category);
    });
    context.read<PostBloc>().add(PostFilterByCategories(selectedCategories));
  }

  void _onCategoryDeselected(String category) {
    setState(() {
      selectedCategories.remove(category);
    });
    context.read<PostBloc>().add(PostFilterByCategories(selectedCategories));
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      context.read<PostBloc>().add(PostFetchAllPosts());
    } else if (index == 1) {
      context.read<PostBloc>().add(PostFetchFavouritePosts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text('Spot Saver'),
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogout());
                  Navigator.pushAndRemoveUntil(
                      context, LoginPage.route(), (route) => false);
                },
                icon: const Icon(Icons.logout),
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
      body: RefreshIndicator(
        onRefresh:
            _currentIndex == 0 ? _refreshPostData : _refreshFavouritesData,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
        }
      },
      builder: (context, state) {
        if (state is PostLoading) {
          return const Loader();
        }
        if (state is PostDisplaySuccess || state is PostFilteredSuccess) {
          final posts = state is PostDisplaySuccess
              ? state.posts
              : (state as PostFilteredSuccess).filteredPosts;

          return Column(
            children: [
              PostCategoryWidget(
                selectedCategories:
                    (context.findAncestorStateOfType<_PostsPageState>()!)
                        .selectedCategories,
                onCategorySelected:
                    (context.findAncestorStateOfType<_PostsPageState>()!)
                        ._onCategorySelected,
                onCategoryDeselected:
                    (context.findAncestorStateOfType<_PostsPageState>()!)
                        ._onCategoryDeselected,
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
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
                        fromFavorites: false,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}
