import 'package:spot_saver/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/core/common/entities/user.dart';
import 'package:spot_saver/features/auth/domain/usecases/change_password.dart';
import 'package:spot_saver/features/auth/domain/usecases/current_user.dart';
import 'package:spot_saver/features/auth/domain/usecases/user_login.dart';
import 'package:spot_saver/features/auth/domain/usecases/user_logout.dart';
import 'package:spot_saver/features/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final UserLogout _userLogout;
  final CurrentUser _currentUser;
  final ChangePassword _changePassword;
  final AppUserCubit _appUserCubit;
  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required UserLogout userLogout,
    required CurrentUser currentUser,
    required ChangePassword changePassword,
    required AppUserCubit appUserCubit,
  })  : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _userLogout = userLogout,
        _currentUser = currentUser,
        _changePassword = changePassword,
        _appUserCubit = appUserCubit,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
    on<AuthLogout>(_onAuthLogout);
    on<AuthChangePassword>(_onAuthChangePassword);
  }

  void _isUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _currentUser(NoParams());

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => _emitAuthSuccess(r, emit),
    );
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    final res = await _userSignUp(UserSignUpParams(
        email: event.email, password: event.password, name: event.name));
    res.fold((failure) => emit(AuthFailure(failure.message)),
        (user) => _emitAuthSuccess(user, emit));
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    final res = await _userLogin(
        UserLoginParams(email: event.email, password: event.password));

    res.fold(
        (l) => emit(AuthFailure(l.message)), (r) => _emitAuthSuccess(r, emit));
  }

  void _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) {
    _userLogout(NoParams());
    emit(AuthLogoutSuccess());
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }

  void _onAuthChangePassword(
      AuthChangePassword event, Emitter<AuthState> emit) async {
    final res = await _changePassword(ChangePasswordParams(
      email: event.email,
      oldPassword: event.oldPassword,
      newPassword: event.newPassword,
    ));

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => emit(AuthChangePasswordSuccess()),
    );
  }
}
