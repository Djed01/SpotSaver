import 'package:spot_saver/core/constants/constants.dart';
import 'package:spot_saver/core/error/exceptions.dart';
import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/network/connection_checker.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:spot_saver/core/common/entities/user.dart';
import 'package:spot_saver/features/auth/data/models/user_model.dart';
import 'package:spot_saver/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  const AuthRepositoryImpl(
    this.remoteDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        // If there is no internet connection login user
        // By using local storage data (offline)
        final session = remoteDataSource.currentUserSession;
        if (session == null) {
          return left(Failure('User not logged in!'));
        }

        return right(
          UserModel(
            id: session.user.id,
            email: session.user.email ?? '',
            name: '',
          ),
        );
      }
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure('User not logged in!'));
      }
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword(
      {required String email, required String password}) async {
    return _getUser(
      () async => await remoteDataSource.loginWithEmailPassword(
          email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword(
      {required String name,
      required String email,
      required String password}) async {
    return _getUser(
      () async => await remoteDataSource.signUpWithEmailPassword(
          name: name, email: email, password: password),
    );
  }

  Future<Either<Failure, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final user = await fn();
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, NoParams>> logout() {
    return remoteDataSource.logout();
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      await remoteDataSource.changePassword(
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      return right(null); // Password changed successfully
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
