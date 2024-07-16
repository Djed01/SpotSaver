import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';

import 'package:spot_saver/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:spot_saver/core/constants/constants.dart';
import 'package:spot_saver/core/theme/app_pallete.dart';
import 'package:spot_saver/core/utils/format_date.dart';
import 'package:spot_saver/features/comment/presentation/widgets/comments.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:spot_saver/features/post/presentation/bloc/post_bloc.dart';
import 'package:spot_saver/core/common/widgets/loader.dart';
import 'package:spot_saver/features/post/presentation/pages/edit_post_page.dart';

class PostViewPage extends StatefulWidget {
  static route(Post post, SourcePage sourcePage) => MaterialPageRoute(
        builder: (context) => PostViewPage(post: post, sourcePage: sourcePage),
      );

  final Post post;
  final SourcePage sourcePage;

  const PostViewPage({
    required this.post,
    required this.sourcePage,
    super.key,
  });

  @override
  PostViewPageState createState() => PostViewPageState();
}

class PostViewPageState extends State<PostViewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isFavorite = false;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    context.read<PostBloc>().add(PostFetchFavouritePosts());
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                isDeleting = true;
              });
              context.read<PostBloc>().add(PostDelete(postId: widget.post.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) async {
        switch (widget.sourcePage) {
          case SourcePage.home:
            context.read<PostBloc>().add(PostFetchAllPosts(fetchFresh: false));
            break;
          case SourcePage.favourites:
            context
                .read<PostBloc>()
                .add(PostFetchFavouritePosts(fetchFresh: false));
            break;
          case SourcePage.myposts:
            context.read<PostBloc>().add(PostFetchUserPosts(fetchFresh: false));
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spot Saver'),
          centerTitle: true,
          actions: [
            BlocConsumer<PostBloc, PostState>(
              listener: (context, state) {
                if (state is PostToggleFavouriteSuccess &&
                    state.post.id == widget.post.id) {
                  setState(() {
                    isFavorite = state.isFavourite;
                  });
                  _controller
                      .forward(from: 0.0)
                      .then((_) => _controller.reset());
                } else if (state is PostDeleteSuccess) {
                  Navigator.of(context).pop();
                } else if (state is PostFailure) {
                  setState(() {
                    isDeleting = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error)),
                  );
                }
              },
              builder: (context, state) {
                if (state is PostFavouritesSuccess) {
                  isFavorite =
                      state.favouritePosts.any((b) => b.id == widget.post.id);
                }

                return IconButton(
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                    BlocProvider.of<PostBloc>(context)
                        .add(PostToggleFavourite(widget.post.id));
                    // Trigger animation immediately
                    _controller.repeat();
                  },
                  icon: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return RotationTransition(
                        turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                        child: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          key: ValueKey(isFavorite),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: isDeleting
            ? const Center(child: Loader())
            : Scrollbar(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'By ${widget.post.posterName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  formatDateBydMMMYYYY(widget.post.updatedAt),
                                  style: const TextStyle(
                                    color: AppPallete.greyColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                BlocBuilder<AppUserCubit, AppUserState>(
                                  builder: (context, state) {
                                    if (state is AppUserLoggedIn &&
                                        state.user.id == widget.post.posterId) {
                                      return IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            EditPostPage.route(widget.post),
                                          );
                                        },
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                                BlocBuilder<AppUserCubit, AppUserState>(
                                  builder: (context, state) {
                                    if (state is AppUserLoggedIn &&
                                        state.user.id == widget.post.posterId) {
                                      return IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(
                                              context);
                                        },
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.post.imageUrl,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: Colors.white,
                                  ),
                                );
                              }
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: AppPallete.greyColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.post.content,
                          style: const TextStyle(fontSize: 16, height: 2),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                widget.post.latitude,
                                widget.post.longitude,
                              ),
                              zoom: 14,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(widget.post.id.toString()),
                                position: LatLng(
                                  widget.post.latitude,
                                  widget.post.longitude,
                                ),
                              ),
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 3,
                          child: CommentsWidget(postId: widget.post.id),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
