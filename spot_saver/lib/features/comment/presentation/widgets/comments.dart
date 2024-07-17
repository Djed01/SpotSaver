import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_saver/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:spot_saver/core/constants/constants.dart';
import 'package:spot_saver/core/utils/show_snackbar.dart';
import 'package:spot_saver/features/comment/domain/entities/comment.dart';
import 'package:spot_saver/features/comment/presentation/bloc/comment_bloc.dart';
import 'package:spot_saver/features/comment/presentation/widgets/comment.dart';

class CommentsWidget extends StatefulWidget {
  final String postId;

  const CommentsWidget({super.key, required this.postId});

  @override
  State<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  final ScrollController _controller = ScrollController();
  Comment? _editingComment;
  List<Comment> comments = [];
  int page = 0;
  bool isLoading = false;
  bool hasMore = true;
  bool _isAddingComment = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollListener);
    _fetchComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent &&
        !isLoading &&
        hasMore) {
      _fetchComments();
    }
  }

  Future<void> _fetchComments() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    context.read<CommentBloc>().add(CommentFetchComments(page, widget.postId));
  }

  void _onCommentsFetched(List<Comment> newComments) {
    setState(() {
      if (newComments.length < Constants.numberOfCommentsPerRequest) {
        hasMore = false;
      }
      page++;
      comments.addAll(newComments);
      isLoading = false;
    });
  }

  void _onCommentAdded(Comment comment) async {
    setState(() {
      _isAddingComment = false;
      _editingComment = null;
    });
    await _refreshCommentData();
  }

  void _onCommentUpdated(Comment comment) async {
    setState(() {
      _isAddingComment = false;
      _editingComment = null;
    });
    await _refreshCommentData();
  }

  void _startEditingComment(Comment comment) {
    setState(() {
      _editingComment = comment;
      _textController.text = comment.content;
    });
  }

  void _onCommentDeleted(String commentId) {
    setState(() {
      comments.removeWhere((comment) => comment.id == commentId);
    });
    showSnackBar(context, "Comment deleted");
  }

  Future<void> _refreshCommentData() async {
    setState(() {
      page = 0;
      comments.clear();
      hasMore = true;
    });
    await _fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentError) {
          showSnackBar(context, state.message);
        } else if (state is CommentLoaded) {
          _onCommentsFetched(state.comments);
        } else if (state is CommentAdded) {
          _onCommentAdded(state.comment);
        } else if (state is CommentUpdated) {
          _onCommentUpdated(state.comment);
        } else if (state is CommentDeleted) {
          _onCommentDeleted(state.commentId);
        }
      },
      builder: (context, state) {
        if (state is CommentLoading && comments.isEmpty) {
          return Stack(
            children: [
              const Column(
                children: [
                  Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  SizedBox(height: 70),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            labelText: 'Add a comment...',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      _isAddingComment
                          ? const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _isAddingComment
                                  ? null
                                  : () {
                                      if (_textController.text.isNotEmpty) {
                                        final userState = context
                                            .read<AppUserCubit>()
                                            .state as AppUserLoggedIn;
                                        final userId = userState.user.id;

                                        setState(() {
                                          _isAddingComment = true;
                                        });

                                        context.read<CommentBloc>().add(
                                              CommentAddComment(
                                                postId: widget.postId,
                                                userId: userId,
                                                content: _textController.text,
                                              ),
                                            );

                                        _textController.clear();
                                      }
                                    },
                            ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshCommentData,
                    child: ListView.builder(
                      controller: _controller,
                      itemCount: comments.length + 1,
                      itemBuilder: (context, index) {
                        if (index < comments.length) {
                          return CommentWidget(
                            comment: comments[index],
                            onEdit: _startEditingComment,
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: hasMore
                                  ? const CircularProgressIndicator()
                                  : const Text('No comments to load'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 70),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          labelText: _editingComment != null
                              ? 'Update a comment...'
                              : 'Add a comment...',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    _isAddingComment
                        ? const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _isAddingComment
                                ? null
                                : () {
                                    if (_textController.text.isNotEmpty) {
                                      final userState = context
                                          .read<AppUserCubit>()
                                          .state as AppUserLoggedIn;
                                      final userId = userState.user.id;

                                      setState(() {
                                        _isAddingComment = true;
                                      });

                                      if (_editingComment != null) {
                                        context.read<CommentBloc>().add(
                                              CommentUpdateComment(
                                                comment:
                                                    _editingComment!.copyWith(
                                                  content: _textController.text,
                                                ),
                                              ),
                                            );
                                      } else {
                                        context.read<CommentBloc>().add(
                                              CommentAddComment(
                                                postId: widget.postId,
                                                userId: userId,
                                                content: _textController.text,
                                              ),
                                            );
                                      }

                                      _textController.clear();
                                    }
                                  },
                          ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
