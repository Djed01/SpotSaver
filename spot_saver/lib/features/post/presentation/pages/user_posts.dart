import 'package:spot_saver/core/common/widgets/loader.dart';
import 'package:spot_saver/core/theme/app_pallete.dart';
import 'package:spot_saver/core/utils/show_snackbar.dart';
import 'package:spot_saver/features/post/presentation/bloc/post_bloc.dart';
import 'package:spot_saver/features/post/presentation/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserPostsPage extends StatelessWidget {
  const UserPostsPage({super.key});

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
        if (state is PostUserPostsSuccess) {
          final posts = state.userPosts;

          return Scaffold(
            appBar: AppBar(
              title: const Text('My Posts'),
              centerTitle: true,
            ),
            body: Scrollbar(
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
                    fromFavorites: true,
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
