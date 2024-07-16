import 'package:spot_saver/core/error/exceptions.dart';
import 'package:spot_saver/features/comment/data/models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spot_saver/core/constants/constants.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getComments(int pageKey, String postId);
  Future<CommentModel> addComment(CommentModel comment);
  Future<void> deleteComment({required String commentId});
  Future<CommentModel> updateComment(CommentModel comment);
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final SupabaseClient supabaseClient;

  CommentRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<CommentModel>> getComments(int pageKey, String postId) async {
    try {
      // Calculate pagination parameters based on pageKey
      int start = pageKey * Constants.numberOfCommentsPerRequest; // Start index
      int end = start + Constants.numberOfCommentsPerRequest - 1; // End index

      // Fetch comments from Supabase with pagination and ordering
      final comments = await supabaseClient
          .from('comments')
          .select('*, profiles (name)')
          .eq('post_id', postId)
          .order('created_at', ascending: false)
          .range(start, end);

      return comments
          .map((comment) => CommentModel.fromJson(comment).copyWith(
                posterName: comment['profiles']['name'],
              ))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CommentModel> addComment(CommentModel comment) async {
    try {
      final commentData = await supabaseClient
          .from('comments')
          .insert(comment.toJson())
          .select();

      return CommentModel.fromJson(commentData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteComment({required String commentId}) async {
    try {
      // Delete the comment data
      await supabaseClient.from('comments').delete().eq('id', commentId);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } on PostgrestException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CommentModel> updateComment(CommentModel comment) async {
    try {
      final commentData = await supabaseClient
          .from('comments')
          .update(comment.toJson())
          .eq('id', comment.id)
          .select()
          .single();

      return CommentModel.fromJson(commentData);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
