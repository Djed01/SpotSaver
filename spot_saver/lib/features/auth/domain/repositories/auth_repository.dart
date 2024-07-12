import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/common/entities/user.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, NoParams>> logout();

  Future<Either<Failure, User>> currentUser();

  Future<Either<Failure, void>> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  });
}
