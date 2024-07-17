import 'package:flutter/material.dart';
import 'package:spot_saver/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:spot_saver/features/comment/domain/entities/comment.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_saver/features/comment/presentation/bloc/comment_bloc.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final Function(Comment) onEdit;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final userState = context.read<AppUserCubit>().state as AppUserLoggedIn;
    final userId = userState.user.id;

    bool isEditable = comment.userId == userId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            radius: 20,
            child: const Icon(
              Icons.person,
              size: 20,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                              text: comment.posterName ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: ' • ',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            TextSpan(
                              text: DateFormat('MMM dd, yyyy')
                                  .format(comment.createdAt),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isEditable)
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: const Icon(Icons.edit),
                                      title: const Text('Edit'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        onEdit(comment);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text('Delete'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _showDeleteConfirmationDialog(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
                Text(comment.content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Comment"),
          content: const Text("Are you sure you want to delete this comment?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                BlocProvider.of<CommentBloc>(context).add(
                  CommentDeleteComment(commentId: comment.id),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
