import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spot_saver/core/theme/app_pallete.dart';
import 'package:spot_saver/core/utils/format_date.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:spot_saver/features/post/presentation/bloc/post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostViewPage extends StatefulWidget {
  static route(Post post, bool fromFavorites) => MaterialPageRoute(
        builder: (context) =>
            PostViewPage(post: post, fromFavorites: fromFavorites),
      );

  final Post post;
  final bool fromFavorites;

  const PostViewPage({
    required this.post,
    required this.fromFavorites,
    super.key,
  });

  @override
  PostViewPageState createState() => PostViewPageState();
}

class PostViewPageState extends State<PostViewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    context.read<PostBloc>().add(PostFetchFavouritePosts());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) async {
        if (widget.fromFavorites) {
          context
              .read<PostBloc>()
              .add(PostFetchFavouritePosts(fetchFresh: false));
        } else {
          context.read<PostBloc>().add(PostFetchAllPosts(fetchFresh: false));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spot Saver'),
          centerTitle: true,
          actions: [
            BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state is PostFavouritesSuccess) {
                  isFavorite =
                      state.favouritePosts.any((b) => b.id == widget.post.id);
                } else if (state is PostToggleFavouriteSuccess &&
                    state.post.id == widget.post.id) {
                  isFavorite = state.isFavourite;
                }

                return IconButton(
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                    BlocProvider.of<PostBloc>(context)
                        .add(PostToggleFavourite(widget.post.id));
                    // Trigger animation immediately
                    _controller.forward(from: 0.0);
                  },
                  icon: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return RotationTransition(
                        turns: _controller,
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
        body: Scrollbar(
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
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.post.imageUrl,
                      errorBuilder: (context, error, stackTrace) => const Icon(
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
