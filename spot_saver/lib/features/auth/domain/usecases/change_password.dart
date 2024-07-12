import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ChangePassword implements UseCase<void, ChangePasswordParams> {
  final AuthRepository authRepository;
  const ChangePassword(this.authRepository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    return await authRepository.changePassword(
        email: params.email,
        oldPassword: params.oldPassword,
        newPassword: params.newPassword);
  }
}

class ChangePasswordParams {
  final String email;
  final String oldPassword;
  final String newPassword;

  ChangePasswordParams(
      {required this.email,
      required this.oldPassword,
      required this.newPassword});
}
