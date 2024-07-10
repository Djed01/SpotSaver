import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spot_saver/core/constants/constants.dart';
import 'package:spot_saver/features/post/domain/entities/post.dart';
import 'package:spot_saver/features/post/presentation/pages/post_view_page.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final Color color;
  final Color textColor;
  final SourcePage sourcePage;

  const PostCard({
    super.key,
    required this.post,
    required this.color,
    required this.textColor,
    required this.sourcePage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PostViewPage.route(post, sourcePage),
        );
      },
      child: Container(
        height: 350,
        margin: const EdgeInsets.all(16).copyWith(bottom: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(
                post.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
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
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: post.categories
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Chip(
                                label: Text(e),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
